class AddIncomeOutcomeAndAmountToPayToEvidenceCheck < ActiveRecord::Migration[5.2]
  def change
    add_column :evidence_checks, :income, :integer
    add_column :evidence_checks, :outcome, :string
    add_column :evidence_checks, :amount_to_pay, :integer
  end
end
