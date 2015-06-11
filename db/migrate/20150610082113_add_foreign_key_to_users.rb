class AddForeignKeyToUsers < ActiveRecord::Migration
  def change
    add_foreign_key :users, :offices
  end
end
