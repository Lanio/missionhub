class Label < ActiveRecord::Base
  attr_accessible :i18n, :name, :organization_id, :created_at, :updated_at
  # added :created_at and :updated_at for migration only

  DEFAULT_LABELS = ["involved", "leader"] # in DSC ORDER by SUPERIORITY
  DEFAULT_CRU_LABELS = ["involved", "engaged_disciple", "leader"]
  DEFAULT_BRIDGE_LABELS = DEFAULT_CRU_LABELS + ["seeker"]

  has_many :people, through: :organizational_labels
  has_many :organizational_labels, dependent: :destroy
  belongs_to :organization

  validates :i18n, uniqueness: true, allow_nil: true
  validates :name, presence: true, :if => Proc.new { |label| organization_id != 0 }
  validates :organization_id, presence: true

  scope :default, where(organization_id: 0)

  scope :default_labels, lambda { {
    :conditions => "i18n IN #{self.default_labels_for_field_string(self::DEFAULT_LABELS)}",
    :order => "FIELD#{self.i18n_field_plus_default_labels_for_field_string(self::DEFAULT_LABELS)}"
  }}
  scope :default_cru_labels, lambda { {
    :conditions => "i18n IN #{self.default_labels_for_field_string(self::DEFAULT_CRU_LABELS)}",
    :order => "FIELD#{self.i18n_field_plus_default_labels_for_field_string(self::DEFAULT_CRU_LABELS)}"
  }}
  scope :default_bridge_labels, lambda { {
    :conditions => "i18n IN #{self.default_labels_for_field_string(self::DEFAULT_BRIDGE_LABELS)}",
    :order => "FIELD#{self.i18n_field_plus_default_labels_for_field_string(self::DEFAULT_BRIDGE_LABELS)}"
  }}
  scope :non_default_labels, lambda { {
    :conditions => "i18n IS NULL",
    :order => "labels.name ASC"
  }}
  scope :arrange_all, lambda {{
    order: "FIELD#{self.i18n_field_plus_default_labels_for_field_string(self::DEFAULT_CRU_LABELS.reverse)} DESC, name"
  }}
  scope :arrange_all_desc, lambda {{
    order: "FIELD#{self.i18n_field_plus_default_labels_for_field_string(self::DEFAULT_CRU_LABELS.reverse)} ASC, name DESC"
  }}

  def self.involved
    @involved ||= Label.find_or_create_by_name_and_i18n_and_organization_id('Involved', 'involved', 0)
  end

  def self.engaged_disciple
    @engaged_disciple ||= Label.find_or_create_by_name_and_i18n_and_organization_id('Engaged Disciple', 'engaged_disciple', 0)
  end

  def self.leader
    @leader ||= Label.find_or_create_by_name_and_i18n_and_organization_id('Leader', 'leader', 0)
  end

  def self.seeker
    @seeker ||= Label.find_or_create_by_name_and_i18n_and_organization_id('Seeker', 'seeker', 0)
  end

  def self.default_labels_for_field_string(labels)
    labels_string = "("
    labels.each do |r|
      labels_string = labels_string + "\"" + r + "\"" + ","
    end
    labels_string[labels_string.length-1] = ")"
    labels_string
  end

  def self.custom_field_plus_default_labels_for_field_string(custom_field, labels)
    r = self.default_labels_for_field_string(labels)
    r[0] = ""
    r = "(#{custom_field}," + r
    r
  end

  def self.i18n_field_plus_default_labels_for_field_string(labels)
    r = self.default_labels_for_field_string(labels)
    r[0] = ""
    r = "(labels.i18n," + r
    r
  end

  def label_contacts_from_org(org)
    people_ids = OrganizationalLabel.where(label_id: id, organization_id: org.id, removed_date: nil).collect(&:person_id).uniq
    people = org.all_people.where(id: people_ids)
  end

  def label_contacts_from_org_with_archived(org)
    people_ids = OrganizationalLabel.where(label_id: id, organization_id: org.id, removed_date: nil).collect(&:person_id).uniq
    people = org.all_people_with_archived.where(id: people_ids)
  end

  def to_s
    name
  end

  if Label.table_exists? # added for travis testing
    LEADER_ID = leader.id
    INVOLVED_ID = involved.id
    ENGAGED_DISCIPLE = engaged_disciple.id
    SEEKER_ID = seeker.id
  end
  NO_SELECTED_LABEL = ["No label",1]
  ANY_SELECTED_LABEL = ["Any",2]
	ALL_SELECTED_LABEL = ["All",3]
	LABEL_SEARCH_FILTERS = [NO_SELECTED_LABEL, ANY_SELECTED_LABEL, ALL_SELECTED_LABEL]

end
