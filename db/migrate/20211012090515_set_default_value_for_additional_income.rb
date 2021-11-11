class SetDefaultValueForAdditionalIncome < ActiveRecord::Migration[6.0]
  def change
    change_column :hmrc_checks, :additional_income, :integer, default: 0
  end
end
