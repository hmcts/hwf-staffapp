class RenameSpotcheckToEvidenceCheck < ActiveRecord::Migration[5.2]
  def change
    rename_table :spotchecks, :evidence_checks
  end
end
