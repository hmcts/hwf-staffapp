class AddIndexToAplicants < ActiveRecord::Migration[5.2]
  def change
    add_index :applicants, :first_name
    add_index :applicants, :last_name
    add_index :applicants, :ni_number
  end
end
