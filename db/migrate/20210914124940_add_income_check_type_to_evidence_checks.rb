class AddIncomeCheckTypeToEvidenceChecks < ActiveRecord::Migration[6.0]
  def change
    add_column :evidence_checks, :income_check_type, :string
  end
end
