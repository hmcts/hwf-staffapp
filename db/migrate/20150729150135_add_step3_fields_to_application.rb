class AddStep3FieldsToApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :applications, :threshold, :decimal
    add_column :applications, :threshold_exceeded, :boolean
    add_column :applications, :over_61, :boolean
  end
end
