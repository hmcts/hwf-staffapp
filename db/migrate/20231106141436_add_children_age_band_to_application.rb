class AddChildrenAgeBandToApplication < ActiveRecord::Migration[7.0]
  def change
    add_column :applications, :children_age_band, :text
  end
end
