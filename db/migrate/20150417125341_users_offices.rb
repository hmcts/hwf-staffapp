class UsersOffices < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :office_id, :integer
  end
end
