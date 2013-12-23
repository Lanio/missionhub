class Apis::V3::DevicesController < Apis::V3::BaseController

  def index

    devices = @current_user.person.devices

    render json: devices,
           callback: params[:callback],
           scope: :active
  end

  def register

    device              = Device.new
    device.device_token = params[:device_token] || nil
    device.platform     = params[:platform] || nil
    device.person_id    = @current_user.person.id
    device.deleted_at   = nil

    if device.save

      Device.find_all_by_device_token(device.device_token).each do |existing_device|
        unless existing_device.id == device.id
            existing_device.destroy
        end
      end

      render json: device,
             status: :created,
             callback: params[:callback],
             scope: :active
    else
      render json: {errors: device.errors.full_messages},
             status: :unprocessable_entity,
             callback: params[:callback]
    end
  end

  def deregister

    device_token  = params[:device_token] || nil

    if device_token
      Device.find_all_by_device_token(device_token).each do |device|
        device.deleted_at = Time.now
      end

      render json: device,
             callback: params[:callback],
             scope: {include: includes}
    else
      render json: {errors: "You need a device token to deregister"},
             status: :unprocessable_entity,
             callback: params[:callback]
    end
  end

end
