class AddIndexToAplicants < ActiveRecord::Migration
  def change
    add_index :applicants, :first_name
    add_index :applicants, :last_name
    add_index :applicants, :ni_number
  end
end
