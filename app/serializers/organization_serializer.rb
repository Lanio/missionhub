class OrganizationSerializer < ActiveModel::Serializer
  INCLUDES = [:contacts, :admins, :users, :leaders, :people, :surveys, :groups, :keywords, :labels, :interaction_types]

  attributes :id, :name, :terminology, :ancestry, :show_sub_orgs, :status, :created_at, :updated_at

  has_many *INCLUDES

  def include_associations!
    includes = scope if scope.is_a? Array
    includes = scope[:include] if scope.is_a? Hash
    includes.each do |rel|
      include!(rel.to_sym) if INCLUDES.include?(rel.to_sym)
    end if includes
  end

  INCLUDES.each do |relationship|
    next if relationship == :leaders
    define_method(relationship) do
      add_since(object.send(relationship))
    end
  end

  def leaders
    add_since(object.send(:users))
  end

end

