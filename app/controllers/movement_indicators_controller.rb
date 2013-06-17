class MovementIndicatorsController < ApplicationController
  def index
  end

  def create
    if current_organization.last_push_to_infobase >= current_organization.last_week
      # don't do anything
    else
      current_organization.push_to_infobase(params)
    end
  end
end
