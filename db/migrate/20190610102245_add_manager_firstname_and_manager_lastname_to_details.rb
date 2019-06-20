class AddManagerFirstnameAndManagerLastnameToDetails < ActiveRecord::Migration
  def change
    add_column :details, :fee_manager_firstname, :string
    add_column :details, :fee_manager_lastname, :string
  end
end
