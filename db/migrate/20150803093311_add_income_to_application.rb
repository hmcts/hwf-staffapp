class AddIncomeToApplication < ActiveRecord::Migration
  def change
    add_column :applications, :income, :integer
  end
end
