class AddManagerFirstnameAndManagerLastnameToDetails < ActiveRecord::Migration[5.2]
  def change
    add_column :details, :fee_manager_firstname, :string
    add_column :details, :fee_manager_lastname, :string
  end
end
