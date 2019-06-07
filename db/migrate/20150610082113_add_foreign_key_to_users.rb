class AddForeignKeyToUsers < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :users, :offices
  end
end
