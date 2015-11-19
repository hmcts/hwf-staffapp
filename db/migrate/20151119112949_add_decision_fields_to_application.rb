class AddDecisionFieldsToApplication < ActiveRecord::Migration
  def change
    add_column :applications, :decision, :string
    add_column :applications, :decision_type, :string
  end
end
