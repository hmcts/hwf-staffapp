class UserOfficeConstraint < ActiveRecord::Migration[5.2]
  def change
    change_column_null :users, :office_id, false
  end
end
