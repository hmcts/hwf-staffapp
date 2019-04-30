class AddIndexToApplication < ActiveRecord::Migration
  def change
    add_index :applications, :state
    add_index :applications, :created_at
    add_index :applications, :decision_date
    add_index :applications, :decision_cost
  end
end
