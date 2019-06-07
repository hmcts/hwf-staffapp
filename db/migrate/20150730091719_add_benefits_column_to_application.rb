class AddBenefitsColumnToApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :applications, :benefits, :boolean
  end
end
