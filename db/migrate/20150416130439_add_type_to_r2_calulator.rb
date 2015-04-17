class AddTypeToR2Calulator < ActiveRecord::Migration
  def change
    add_column :r2_calculators, :type, :string
  end
end
