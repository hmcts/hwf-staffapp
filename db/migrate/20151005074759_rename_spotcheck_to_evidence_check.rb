class RenameSpotcheckToEvidenceCheck < ActiveRecord::Migration
  def change
    rename_table :spotchecks, :evidence_checks
  end
end
