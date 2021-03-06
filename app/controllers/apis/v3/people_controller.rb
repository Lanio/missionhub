class Apis::V3::PeopleController < Apis::V3::BaseController
  before_filter :get_person, only: [:show, :update, :destroy, :archive]

  def index
    render json: filtered_people,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization, since: params[:since], user: current_user}
  end

  def show
    render json: @person,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization, user: current_user}
  end

  def create
    params[:person][:phone_numbers_attributes] = params[:person].delete(:phone_numbers) if params[:person][:phone_numbers]
    params[:person][:email_addresses_attributes] = params[:person].delete(:email_addresses) if params[:person][:email_addresses]
    params[:person][:addresses_attributes] = params[:person].delete(:addresses) if params[:person][:addresses]
    person = Person.find_existing_person(Person.new(params[:person]))

    if person.save

      # add permissions in current org
      permission_ids = params[:permissions].split(',') if params[:permissions]
      permission_ids = [Permission::NO_PERMISSIONS_ID] if permission_ids.blank?
      permission_ids.each do |permission_id|
        current_organization.add_permission_to_person(person, permission_id)
      end

      render json: person,
             status: :created,
             callback: params[:callback],
             scope: {include: includes, organization: current_organization, user: current_user}
    else
      render json: {errors: person.errors.full_messages},
             status: :unprocessable_entity,
             callback: params[:callback]
    end
  end

  def update
    # add permissions in current org
    if params[:permissions]
      params[:permissions].split(',').each do |permission_id|
        current_organization.add_permission_to_person(person, permission_id)
      end
    end

    # remove permissions in current org
    if params[:remove_permissions]
      params[:remove_permissions].split(',').each do |permission_id|
        current_organization.remove_permission_from_person(person, permission_id)
      end
    end

    if params[:person]
      unless @person.update_attributes(params[:person])
        render json: {errors: @person.errors.full_messages},
               status: :unprocessable_entity,
               callback: params[:callback]
        return
      end
    end

    render json: @person,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization, user: current_user}
  end

  def archive
    archive_permissions([@person])
    render json: @person,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization, user: current_user}
  end

  def destroy
    remove_permissions([@person])
    render json: @person,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization, user: current_user}
  end

  def bulk_destroy
    remove_permissions(filtered_people('bulk_destroy'))
    render json: filtered_people,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization},
           root: 'people'
  end

  def bulk_archive
    archive_permissions(filtered_people('bulk_archive'))
    render json: filtered_people,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization},
           root: 'people'
  end

  def ids
    render json: filtered_people.collect { |p| p.id }, root: 'people_ids', callback: params[:callback]
  end

  private

  def people
    current_organization.people
  end

  def get_person
    if params[:id] == "me"
      @person = current_user.person
    else
      @person = add_includes_and_order(people).find(params[:id])
    end
  end

  def filtered_people(process = nil)
    unless @filtered_people
      order = params[:order] || 'last_name, first_name'
      if process == 'bulk_archive'
        @filtered_people = current_organization.not_archived_people
      elsif process == 'bulk_destroy'
        @filtered_people = current_organization.not_deleted_people
      else
        if params[:include_archived] == 'true'
          @filtered_people = current_organization.people
        else
          @filtered_people = current_organization.not_archived_people
        end
      end
      @filtered_people = add_includes_and_order(@filtered_people)
      @filtered_people = PersonOrder.new(order, current_organization).order(@filtered_people) if order
      @filtered_people = PersonFilter.new(params[:filters], current_organization).filter(@filtered_people) if params[:filters]
    end
    @filtered_people
  end

  def remove_permissions(people, permissions = nil)
    permissions = permissions.split(',').collect{|x| x.to_i} if permissions.present?
    current_organization.remove_permissions_from_people(people, permissions)
  end

  def archive_permissions(people, permissions = nil)
    permissions = permissions.split(',').collect{|x| x.to_i} if permissions.present?
    current_organization.archive_permissions_from_people(people, permissions)
  end

  def available_includes
    [:email_addresses, :phone_numbers, :addresses]
  end

end
