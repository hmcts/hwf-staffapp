class AddFregFieldsToOnlineApplications < ActiveRecord::Migration[8.1]
  def change
    add_column :online_applications, :fee_code, :string
    add_column :online_applications, :claim_amount, :decimal
    add_column :online_applications, :fee_version_valid_from, :date
    add_column :online_applications, :fee_entry_method, :string
  end
end
