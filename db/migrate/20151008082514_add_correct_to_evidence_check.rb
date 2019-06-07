class AddCorrectToEvidenceCheck < ActiveRecord::Migration[5.2]
  def change
    add_column :evidence_checks, :correct, :boolean
  end
end
