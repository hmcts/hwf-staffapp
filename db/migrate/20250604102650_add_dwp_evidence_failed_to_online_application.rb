class AddDwpEvidenceFailedToOnlineApplication < ActiveRecord::Migration[8.0]
  def change
    add_column :online_applications, :dwp_manual_decision, :boolean
  end
end
