class AddAdditionalIncomeToHmrcCheck < ActiveRecord::Migration[6.0]
  def change
    add_column :hmrc_checks, :additional_income, :integer
  end
end
