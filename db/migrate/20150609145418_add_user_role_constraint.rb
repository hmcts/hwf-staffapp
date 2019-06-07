class AddUserRoleConstraint < ActiveRecord::Migration[5.2]
  def change
    change_column_null :users, :role, false
  end
end
