class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.text :message
      t.boolean :show, default: false, null: false

      t.timestamps null: false
    end

    Notification.create(show: false)
  end
end
