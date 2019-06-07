class AddIndexToDetail < ActiveRecord::Migration[5.2]
  def change
    add_index :details, :case_number
    add_index :details, :fee
  end
end
