class Apis::V3::InteractionTypesController < Apis::V3::BaseController
  before_filter :get_interaction_type, only: [:show, :update, :destroy]

  def index
    order = params[:order] || 'created_at desc'
    list = add_includes_and_order(interaction_types, order: order)
    render json: list,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization, since: params[:since]}
  end

  def show
    render json: @interaction_type,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  def create
    if current_person.is_user_for_org?(current_organization)
      render_unauthorized_call
    else
      interaction_type = InteractionType.new(params[:interaction_type])
      interaction_type.organization_id = current_organization.id

      if interaction_type.save
        render json: interaction_type,
               status: :created,
               callback: params[:callback],
               scope: {include: includes, organization: current_organization}
      else
        render json: {errors: interaction_type.errors.full_messages},
               status: :unprocessable_entity,
               callback: params[:callback]
      end
    end
  end

  def update
    if current_person.is_user_for_org?(current_organization)
      render_unauthorized_call
    else
      if @interaction_type.organization_id == 0
        render json: {errors: ["You can't update default interaction_types"]},
               status: :unprocessable_entity,
               callback: params[:callback]
      else
        if @interaction_type.update_attributes(params[:interaction_type])
          render json: @interaction_type,
                 callback: params[:callback],
                 scope: {include: includes, organization: current_organization}
        else
          render json: {errors: interaction_type.errors.full_messages},
                 status: :unprocessable_entity,
                 callback: params[:callback]
        end
      end
    end
  end

  def destroy
    if current_person.is_user_for_org?(current_organization)
      render_unauthorized_call
    else
      if @interaction_type.organization_id == 0
        render json: {errors: ["You can't destroy default interaction_types"]},
               status: :unprocessable_entity,
               callback: params[:callback]
      else
        @interaction_type.destroy
        render json: @interaction_type,
               callback: params[:callback],
               scope: {include: includes, organization: current_organization}
      end
    end
  end

  private

  def interaction_types
    current_organization.interaction_types
  end

  def get_interaction_type
    @interaction_type = add_includes_and_order(interaction_types).find(params[:id])
  end

end
