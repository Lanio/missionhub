class EmailAddress < ActiveRecord::Base
end
class OrganizationalPermission < ActiveRecord::Base
end
class Organization < ActiveRecord::Base
end
class Permission < ActiveRecord::Base
end
class UpdatePeoplePermissionToNoPermissionIfNoEmail < ActiveRecord::Migration
  def up
    updated_count = 0
    all = OrganizationalPermission.where("permission_id IN (?)", [Permission::ADMIN_ID, Permission::USER_ID]).order("organization_id asc, person_id asc")
    if all.present?
      all.each do |org_permission|
        person_id = org_permission.person_id
        org_id = org_permission.organization_id
        email_addresses = EmailAddress.where("person_id = ?", person_id)
        unless email_addresses.present?
          OrganizationalPermission.where(person_id: person_id, organization_id: org_id, permission_id: Permission::NO_PERMISSIONS_ID).first_or_create(added_by_id: nil)

          has_already_no_permission = OrganizationalPermission.where(person_id: person_id, organization_id: org_id, permission_id: Permission::NO_PERMISSIONS_ID)

          org_permissions = OrganizationalPermission.where(person_id: person_id, organization_id: org_id)
          org_permissions.where("id <> ?", has_already_no_permission.first.id).destroy_all if has_already_no_permission.present?

          puts "[Organization(#{org_id}) - Person (#{person_id})] Organizational Permission was updated."
          updated_count += 1
        end
      end
    end

    puts "Before migration: Total of organizatinal permissions(Admin/User) is #{all.count}."
    puts "Total of #{updated_count.to_s} organizational permissions without email address."
  end

  def down
  end
end
