class AddTypeToEvidenceCheck < ActiveRecord::Migration
  def change
    add_column :evidence_checks, :check_type, :string
    EvidenceCheck.connection.execute("UPDATE evidence_checks SET check_type='random';")
  end
end
