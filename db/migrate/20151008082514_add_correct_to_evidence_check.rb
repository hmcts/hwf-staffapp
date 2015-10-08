class AddCorrectToEvidenceCheck < ActiveRecord::Migration
  def change
    add_column :evidence_checks, :correct, :boolean
  end
end
