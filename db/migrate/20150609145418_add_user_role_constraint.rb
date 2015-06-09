class AddUserRoleConstraint < ActiveRecord::Migration
  def change
    change_column_null :users, :role, false
  end
end
