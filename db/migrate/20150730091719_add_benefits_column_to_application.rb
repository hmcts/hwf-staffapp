class AddBenefitsColumnToApplication < ActiveRecord::Migration
  def change
    add_column :applications, :benefits, :boolean
  end
end
