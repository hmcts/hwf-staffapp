class RemoveNotNullOnRepresentative < ActiveRecord::Migration[7.0]
  def change
    change_column_null :representatives, :first_name, true
    change_column_null :representatives, :last_name, true
  end
end
