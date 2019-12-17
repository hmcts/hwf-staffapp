class AddIncorrectReasonCategoryToEvidenceChecks < ActiveRecord::Migration[5.2]
  def change
    add_column :evidence_checks, :incorrect_reason_category, :string
  end
end
