class UserOfficeConstraint < ActiveRecord::Migration
  def change
    change_column_null :users, :office_id, false
  end
end
