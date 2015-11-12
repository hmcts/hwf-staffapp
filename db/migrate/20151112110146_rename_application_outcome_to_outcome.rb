class RenameApplicationOutcomeToOutcome < ActiveRecord::Migration
  def change
    rename_column :applications, :application_outcome, :outcome
  end
end
