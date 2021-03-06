class PersonFilter
  attr_accessor :people, :filters

  def initialize(filters, organization = nil)
    @filters = filters
    @organization = organization

    # strip extra spaces from filters
    @filters.collect { |k, v| @filters[k] = v.to_s.strip }

  end

  def filter(people)
    filtered_people = people

    if @filters[:ids].present?
      filtered_people = filtered_people.where('people.id' => @filters[:ids].split(','))
    end

    if @filters[:fb_uids].present?
      filtered_people = filtered_people.where('people.fb_uid' => @filters[:fb_uids].split(','))
    end

    if @filters[:labels].present?
      filtered_people = filtered_people.joins(:organizational_labels).where('organizational_labels.label_id IN (?) AND organizational_labels.organization_id = ? AND organizational_labels.removed_date IS NULL', @filters[:labels].split(','), @organization.id)
    end

    if @filters[:permissions].present?
      filtered_people = filtered_people.where('organizational_permissions.permission_id IN (?) AND organizational_permissions.organization_id = ?', @filters[:permissions].split(','), @organization.id)
    end

    if @filters[:roles]
      permission_ids = @filters[:roles].split(',').collect {|r| r.to_i > 0 ? r : Permission.where(name: r).first.try(:id)}.compact
      label_ids = @filters[:roles].split(',').collect {|r| r.to_i > 0 ? r : Label.where(name: r).first.try(:id)}.compact
      filtered_people = filtered_people.joins(:organizational_labels)
                                       .includes(:organizational_permissions)
                                       .where('(organizational_permissions.permission_id IN (:permission_ids)
                                                AND organizational_permissions.organization_id = :org_id)
                                                OR (organizational_labels.label_id IN (:label_ids)
                                                AND organizational_labels.organization_id = :org_id
                                                AND organizational_labels.removed_date IS NULL)',
                                              permission_ids: permission_ids, label_ids: label_ids, org_id: @organization.id)
    end

    if @filters[:interactions]
      filtered_people = filtered_people.joins(:interactions).where('interactions.organization_id = ? AND interactions.deleted_at IS NULL AND interactions.interaction_type_id IN (?)', @organization.id, @filters[:interactions].split(','))
    end

    if @filters[:first_name_like]
      filtered_people = filtered_people.where("first_name like ? ", "#{@filters[:first_name_like]}%")
    end

    if @filters[:last_name_like]
      filtered_people = filtered_people.where("last_name like ? ", "#{@filters[:last_name_like]}%")
    end

    if @filters[:is_friends_with]
      friend_ids =  $redis.smembers(Friend.redis_key(@filters[:is_friends_with], :following))
      if friend_ids.present?
        filtered_people =  filtered_people.where('people.id' => friend_ids)
      else
        filtered_people = filtered_people.where('1=0')
      end
    end

    if @filters[:name_or_email_like]
      case
      when @filters[:name_or_email_like].split(/\s+/).length > 1
        # Email addresses don't have spaces, so if there's a space, this is probably a name
        @filters[:name_like] = @filters.delete(:name_or_email_like)
      when @filters[:name_or_email_like].include?('@')
        # Names don't typically have @ signs
        @filters[:email_like] = @filters.delete(:name_or_email_like)
      else
        filtered_people = filtered_people.includes(:email_addresses)
                                         .where("concat(first_name,' ',last_name) LIKE :search OR
                                                  first_name LIKE :search OR last_name LIKE :search OR
                                                  email_addresses.email LIKE :search",
                                                 {:search => "#{filters[:name_or_email_like]}%"})
      end
    end

    if @filters[:name_like]
      # See if they've typed a first and last name
      if @filters[:name_like].split(/\s+/).length > 1
        filtered_people = filtered_people.where("concat(first_name,' ',last_name) like ? ", "%#{@filters[:name_like]}%")
      else
        filtered_people = filtered_people.where("first_name like :search OR last_name like :search",
                                                 {search: "#{@filters[:name_like]}%"})
      end
    end

    if @filters[:email_like]
      filtered_people = filtered_people.includes(:email_addresses)
                                         .where("email_addresses.email LIKE :search",
                                                 {:search => "#{filters[:name_or_email_like]}%"})
    end

    if @filters[:gender]
      gender = case
               when @filters[:gender].first.downcase == 'm'
                 1
               when @filters[:gender].first.downcase == 'f'
                 0
               else
                 @filters[:gender]
               end

      filtered_people = filtered_people.where(gender: gender)
    end

    if @filters[:followup_status]
      filtered_people = filtered_people.where('organizational_permissions.followup_status' => @filters[:followup_status].split(','))
      filtered_people = filtered_people.includes(:organizational_permissions) unless filtered_people.to_sql.include?('`organizational_permissions`')
    end

    if @filters[:assigned_to]
      filtered_people = filtered_people.includes(:assigned_tos)
                                       .where('contact_assignments.assigned_to_id' => @filters[:assigned_to].split(','), 'contact_assignments.organization_id' => @organization.id)
    end

      if @filters[:surveys].present?
        filtered_people = filtered_people.joins(:answer_sheets)
                                         .where("answer_sheets.survey_id" => @filters[:surveys].split(','))
      end

    filtered_people
  end
end
