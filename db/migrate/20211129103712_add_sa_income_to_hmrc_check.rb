class AddSaIncomeToHmrcCheck < ActiveRecord::Migration[6.0]
  def change
    add_column :hmrc_checks, :sa_income, :string
  end
end
