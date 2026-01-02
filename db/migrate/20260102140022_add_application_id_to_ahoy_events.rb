class AddApplicationIdToAhoyEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :ahoy_events, :application_id, :integer
    add_index :ahoy_events, :application_id
  end
end
