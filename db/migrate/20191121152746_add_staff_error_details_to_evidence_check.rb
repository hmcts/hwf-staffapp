class AddStaffErrorDetailsToEvidenceCheck < ActiveRecord::Migration[5.2]
  def change
    add_column :evidence_checks, :staff_error_details, :string
  end
end
