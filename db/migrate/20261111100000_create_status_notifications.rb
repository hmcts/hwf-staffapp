class CreateStatusNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :status_notifications do |t|
      t.string :service, null: false
      t.boolean :outage_open, null: false, default: false
      t.integer :sent_count, null: false, default: 0
      t.datetime :last_sent_at
      t.timestamps
    end

    add_index :status_notifications, :service, unique: true
  end
end
