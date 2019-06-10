class AddFirstNameAndLastNameToOnlineApplications < ActiveRecord::Migration
  def change
    add_column :online_applications, :fee_manager_firstname, :string
    add_column :online_applications, :fee_manager_lastname, :string
  end
end
