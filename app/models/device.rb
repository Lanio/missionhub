class Device < ActiveRecord::Base
  attr_accessible :deleted_at, :device_token, :person_id, :platform

  belongs_to :person

  validates_presence_of :person_id, :device_token, :platform
  validates_uniqueness_of :device_token, :scope => :person_id
  after_save :ensure_timestamp

  IOS_PLATFORM = "ios"
  ANDROID_PLATFORM = "android"
  PLATFORMS = [Device::IOS_PLATFORM, Device::ANDROID_PLATFORM]

  REDIS_NOTIFICATION_KEY = "com.missionhub.device.notification.list"

  scope :active,
        where("deleted_at IS NOT NULL")

  scope :person, lambda { |person| { conditions: {person_id: person.id} } }

  def send_notification(message)
    payload                 = {}
    payload['message']      = message || ""
    payload['device_token'] = self.device_token
    payload['platform']     = self.platform

    $redis.rpush(REDIS_NOTIFICATION_KEY, payload_string)
    async(:process_notification_list, nil)
  end

  def process_notification_list
    @list = $redis.lrange(REDIS_NOTIFICATION_KEY, 0, -1)

    while notification_string = @list.pop do
      notification = JSON.parse(notification_string)

      if notification['platform'] == 'ios'
        note = Grocer::Notification.new(
            device_token: notification_json['device_token'],
            alert: notification_json['message'],
            sound: 'default',
            badge: 0
        )
        PUSHER.push(note)
      elsif notification['platform'] == 'android'
        gcm = GCM.new(ENV['gcm_key'])
        registration_id = [notification_json['device_token']]
        options = {
            'data' => {
                'message' => notification_json['message']
            },
            'collapse_key' => 'updated_state'
        }
        response = gcm.send_notification(registration_id, options)
      end
    end
  end

end
