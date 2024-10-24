class AddHmrcIncomeToEvidenceCheck < ActiveRecord::Migration[7.2]
  def change
    add_column :evidence_checks, :hmrc_income_used, :decimal, default: 0
  end
end
