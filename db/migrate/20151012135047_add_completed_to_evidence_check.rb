class AddCompletedToEvidenceCheck < ActiveRecord::Migration[5.2]
  def change
    add_column :evidence_checks, :completed_at, :datetime
    add_reference :evidence_checks, :completed_by, references: :users
  end
end
