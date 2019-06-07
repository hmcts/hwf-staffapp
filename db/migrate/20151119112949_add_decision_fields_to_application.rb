class AddDecisionFieldsToApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :applications, :decision, :string
    add_column :applications, :decision_type, :string
  end
end
