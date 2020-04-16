class RenameNiNumberToRegNumberAtEvidenceCheckFlags < ActiveRecord::Migration[5.2]
  def up
    rename_column :evidence_check_flags, :ni_number, :reg_number
  end

  def down
    rename_column :evidence_check_flags, :reg_number, :ni_number
  end
end
