require 'csv'
require 'open-uri'
require 'contact_methods'
require 'async'
class Import < ActiveRecord::Base
  include Async
  include Sidekiq::Worker
  include ContactMethods

  serialize :headers
  serialize :preview
  serialize :header_mappings

  belongs_to :user
  belongs_to :organization

  has_attached_file :upload, s3_credentials: 'config/s3.yml', s3_permissions: :private, storage: :s3,
                             path: 'mh/imports/:attachment/:id/:filename', s3_storage_class: :reduced_redundancy

  validates :upload, attachment_presence: true

  before_save :parse_headers

  def label_name
    created_at.strftime("Import-%Y-%m-%d")
  end

  def get_new_people # generates array of Person hashes
    new_people = Array.new
    first_name_question = Element.where( :attribute_name => "first_name").first.id.to_s
    email_question = Element.where( :attribute_name => "email").first.id.to_s

    file = URI.parse(upload.expiring_url).read.encode('utf-8', 'iso-8859-1')
    content = CSV.new(file, :headers => :first_row)

    content.each do |row|
      person_hash = Hash.new
      person_hash[:person] = Hash.new
      person_hash[:person][:first_name] = row[header_mappings.invert[first_name_question].to_i]
      person_hash[:person][:email] = row[header_mappings.invert[email_question].to_i] if header_mappings.invert[email_question].present? && row[header_mappings.invert[email_question].to_i].present?

      answers = Hash.new

      header_mappings.keys.each do |k|
        answers[header_mappings[k].to_i] = row[k.to_i] unless header_mappings[k] == '' || header_mappings[k] == 'do_not_import'
      end

      person_hash[:answers] = answers
      new_people << person_hash
    end

    new_people

  end

  def check_for_errors # validating csv
    errors = []

    #since first name is required for every contact. Look for id of element where attribute_name = 'first_name' in the header_mappings.
    first_name_question = Element.where(:attribute_name => "first_name").first.id.to_s
    unless header_mappings.values.include?(first_name_question)
      errors << I18n.t('contacts.import_contacts.present_first_name')
    end

    a = header_mappings.values
    a.delete("")
    do_not_import_count = a.count('do_not_import')
    do_not_import_count -= 1 if do_not_import_count > 0
    if a.length > (a.uniq.length + do_not_import_count) # if they don't have the same length that means the user has selected on at least two of the headers the same selected person attribute/survey question
      return errors << I18n.t('contacts.import_contacts.duplicate_header_match')
    end
    errors
  end

  def queue_import_contacts(labels = [])
    async(:do_import, labels)
  end

  def do_import(labels = [])
    current_organization = Organization.find(organization_id)
    current_user = User.find(user_id)
    import_errors = []
    names = []
    new_person_ids = []
    Person.transaction do
      get_new_people.each do |new_person|
        person = create_contact_from_row(new_person, current_organization)
        new_person_ids << person.id
        names << person.name
        if person.errors.present?
          person.errors.messages.each do |error|
            import_errors << "#{person.to_s}: #{error[0].to_s.split('.')[0].titleize} #{error[1].first}"
          end
        else
        	labels.each do |label_id|
						if label_id.to_i == 0
							label = Label.find_or_create_by_organization_id_and_name(current_organization.id, label_name)
							label_id = label.id
						elsif label_id.to_i == Label::LEADER_ID
							import_errors << "#{person.to_s}: Email address is required to add Leader label" unless person.email_addresses.present?
						end
            unless import_errors.present?
              current_organization.add_contact(person)
  						current_organization.add_label_to_person(person, label_id, current_user.person.id)
            end
					end
        end
      end
      if import_errors.present?
        # send failure email
        ImportMailer.import_failed(current_user, import_errors).deliver
        raise ActiveRecord::Rollback
      else
        # Send success email
        table = create_table(new_person_ids, get_new_people)
        ImportMailer.import_successful(current_user, table).deliver
      end
    end
  end

  def create_contact_from_row(row, current_organization)
		row[:person] = row[:person].each_value {|p| p.strip! if p.present? }
		row[:answers] = row[:answers].each_value {|a| a.strip! if a.present? }

    person = Person.find_existing_person(Person.new(row[:person]))
    person.save

    unless @surveys_for_import
      @survey_ids ||= SurveyElement.where(element_id: row[:answers].keys).pluck(:survey_id) - [APP_CONFIG['predefined_survey']]
      @surveys_for_import = current_organization.surveys.where(id: @survey_ids.uniq)
    end

    question_sets = []

    @surveys_for_import.each do |survey|
      answer_sheet = get_answer_sheet(survey, person)
      question_set = QuestionSet.new(survey.questions, answer_sheet)
      question_set.post(row[:answers], answer_sheet)
      question_sets << question_set
    end

		new_phone_numbers = []
    # Set values for predefined questions
    answer_sheet = AnswerSheet.new(person: person)
    predefined = Survey.find(APP_CONFIG['predefined_survey'])
    predefined.elements.where('object_name is not null').each do |question|
    	answer = row[:answers][question.id]
    	if answer.present?
    		#set response
	    	question.set_response(answer, answer_sheet)

	    	#create unique phone number but not a primary
	    	if question.attribute_name == "phone_number"
	    		numbers = person.phone_numbers
	    		if numbers.find_by_primary(true).present?
    				new_phone_numbers << person.phone_numbers.new(number: answer, primary: false) unless numbers.where("number = ?", answer).present?
	    		end
	    	end
	   	end
    end

    if person.save
      question_sets.map { |qs| qs.save }
      new_phone_numbers.map { |pn| pn.save if pn.number.present? }
      contact_permission = create_contact_at_org(person, current_organization)
      # contact_permission.update_attribute('followup_status','uncontacted') # Set default
    end

    return person
  end

  class NilColumnHeader < StandardError

  end

  class InvalidCSVFormat < StandardError

  end

  private

  def create_table(new_person_ids, excel_answers)
    @answered_question_ids = header_mappings.values.reject{ |c| c.empty? || c == 'do_not_import' }.collect(&:to_i)

    @table = []
    questions = []
    @answered_question_ids.each do |a|
      questions << Element.find(a).label
    end
    @table << questions

    if excel_answers.present?
		  excel_answers.each do |new_person|
	  		all_answers = []
		  	@answered_question_ids.each do |q|
		  		all_answers << new_person[:answers][q]
		  	end
	  		@table << all_answers
		  end
		end
		@table
  end

  def parse_headers
    return unless upload?
    tempfile = upload.queued_for_write[:original]

    # Since we have to encode the csv file to avoid the "invalid byte sequence in utf-8" error
    # And import has no format validation, this line is the safest and lightest format validation
    # Rather than to set the validation from model, it's too strict.
    raise InvalidCSVFormat unless File.extname(upload.original_filename) == ".csv"

    unless tempfile.nil?
      ctr = 0
      CSV.foreach(tempfile.path, 'r:iso-8859-1:utf-8') do |row|
        Rails.logger.info "---COLLECT#{ctr}---"
        if ctr == 0
          begin
            # if there is a nil headers
            raise NilColumnHeader if row && row.length - row.compact.length != 0
            self.headers = row.compact
          rescue
            raise NilColumnHeader
          end
          raise NilColumnHeader if headers.empty?
        elsif ctr == 1
          self.preview = row
        else
          break
        end
        ctr += 1
      end
    end
  end

  def is_row_blank?(row)
    #checking if a row has no entries (because of the possibility of user entering in a blank row in a csv file)
    row.each do |r|
      return false if !r.nil?
    end
    true
  end

end
