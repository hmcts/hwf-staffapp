class AddStep3FieldsToApplication < ActiveRecord::Migration
  def change
    add_column :applications, :threshold_exceeded, :boolean
    add_column :applications, :over_61, :boolean
  end
end
