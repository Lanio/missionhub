class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.integer :person_id
      t.string :device_token
      t.string :platform
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
