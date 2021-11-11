class UpdateHmrcCheck < ActiveRecord::Migration[6.0]
  def change
    rename_column :hmrc_checks, :application_id, :evidence_check_id
  end
end
