class AddCcmccCheckTypeToEvidenceChecksTable < ActiveRecord::Migration[5.2]
  def change
    add_column :evidence_checks, :ccmcc_check_type, :string
  end
end
