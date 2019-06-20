class AddFirstNameAndLastNameToOnlineApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :online_applications, :fee_manager_firstname, :string
    add_column :online_applications, :fee_manager_lastname, :string
  end
end
