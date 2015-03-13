class AddNameToUser < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    User.connection.execute("UPDATE users SET name = LEFT(email, POSITION('@' IN email)-1);")
  end
end
