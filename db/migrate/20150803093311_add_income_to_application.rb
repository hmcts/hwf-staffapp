class AddIncomeToApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :applications, :income, :integer
  end
end
