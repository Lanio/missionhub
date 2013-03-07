class Role < ActiveRecord::Base
  has_paper_trail :on => [:destroy],
                  :meta => { organization_id: :organization_id }

  has_many :people, through: :organizational_roles
  has_many :organizational_roles, inverse_of: :role, dependent: :destroy
  belongs_to :organization, inverse_of: :roles
  scope :default, where(organization_id: 0)
	scope :leaders, where(i18n: %w[leader admin])


  validates :i18n, uniqueness: true, allow_nil: true
  validates :name, presence: true, :if => Proc.new { |role| organization_id != 0 }
  validates :organization_id, presence: true

  scope :default_roles_desc, lambda { {
    :conditions => "i18n IN #{self.default_roles_for_field_string(self::DEFAULT_ROLES)}",
    :order => "FIELD#{self.i18n_field_plus_default_roles_for_field_string(self::DEFAULT_ROLES)}"
  }}

  scope :default_cru_roles_desc, lambda { {
    :conditions => "i18n IN #{self.default_roles_for_field_string(self::DEFAULT_CRU_ROLES)}",
    :order => "FIELD#{self.i18n_field_plus_default_roles_for_field_string(self::DEFAULT_CRU_ROLES)}"
  }}

  scope :non_default_roles_asc, lambda { {
    :conditions => "i18n IS NULL",
    :order => "roles.name ASC"
  }}

  scope :arrange_all, lambda {{
    order: "FIELD#{self.default_roles_for_field_string(self::DEFAULT_CRU_ROLES)}"
  }}
  
  def members_from_role_org(org_id, include_archive = false)
  	is_archived = include_archive ? "" : "AND archive_date IS NULL"
		organizational_roles.where("organization_id = ? AND (followup_status <> 'do_not_contact' OR followup_status IS NULL) #{is_archived}", org_id)
  end
    
  def self.leader_ids
    @leader_ids ||= self.leaders.collect(&:id)
  end

  def self.involved_ids
    @involved_ids ||= self.where(i18n: %w[leader admin involved]).pluck(:id)
  end

  def self.admin
    @admin ||= Role.find_or_create_by_i18n_and_organization_id('admin', 0)
  end

  def self.leader
    @leader ||= Role.find_or_create_by_i18n_and_organization_id('leader', 0)
  end

  def self.contact
    @contact ||= Role.find_or_create_by_i18n_and_organization_id('contact', 0)
  end

  def self.involved
    @involved ||= Role.find_or_create_by_i18n_and_organization_id('involved', 0)
  end

  def self.alumni
    @alumni ||= Role.find_or_create_by_i18n_and_organization_id('alumni', 0)
  end

  def self.sent
    @sent ||= Role.find_or_create_by_i18n_and_organization_id('sent', 0)
  end

  def to_s
    organization_id == 0 ? I18n.t("roles.#{i18n}") : name
  end

    def self.default_roles_for_field_string(roles)
      roles_string = "("
      roles.each do |r|
        roles_string = roles_string + "\"" + r + "\"" + ","
      end
      roles_string[roles_string.length-1] = ")"
      roles_string
    end

    def self.i18n_field_plus_default_roles_for_field_string(roles)
      r = self.default_roles_for_field_string(roles)
      r[0] = ""
      r = "(roles.i18n," + r
      r
    end

  ADMIN_ID = admin.id
  LEADER_ID = leader.id
  CONTACT_ID = contact.id
  INVOLVED_ID = involved.id
  SENT_ID = sent.id
  ALUMNI_ID = alumni.id

  DEFAULT_ROLES = ["admin", "leader", "involved", "alumni", "contact"] # in DSC ORDER by SUPERIORITY
  CRU_ONLY_ROLES = ["sent"]
  DEFAULT_CRU_ROLES = DEFAULT_ROLES + CRU_ONLY_ROLES

  ANY_SELECTED_LABEL = ["Any",1]
	ALL_SELECTED_LABEL = ["All",2]
	LABEL_SEARCH_FILTERS = [ANY_SELECTED_LABEL, ALL_SELECTED_LABEL]
end
