class RenameApplicationOutcomeToOutcome < ActiveRecord::Migration[5.2]
  def change
    rename_column :applications, :application_outcome, :outcome
  end
end
