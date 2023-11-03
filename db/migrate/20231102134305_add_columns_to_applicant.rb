class AddColumnsToApplicant < ActiveRecord::Migration[7.0]
  def change
    add_column :applicants, :partner_first_name, :string
    add_column :applicants, :partner_last_name, :string
    add_column :applicants, :partner_ni_number, :string
    add_column :applicants, :partner_date_of_birth, :date
  end
end
