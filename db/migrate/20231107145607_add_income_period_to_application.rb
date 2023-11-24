class AddIncomePeriodToApplication < ActiveRecord::Migration[7.0]
  def change
    add_column :applications, :income_period, :string
  end
end
