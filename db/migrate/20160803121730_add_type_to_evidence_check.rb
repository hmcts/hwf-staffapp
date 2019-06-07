class AddTypeToEvidenceCheck < ActiveRecord::Migration[5.2]
  def change
    add_column :evidence_checks, :check_type, :string
    EvidenceCheck.connection.execute("UPDATE evidence_checks SET check_type='random';")
  end
end
