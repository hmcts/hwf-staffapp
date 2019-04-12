class AddIndexToDetail < ActiveRecord::Migration
  def change
    add_index :details, :case_number
    add_index :details, :fee
  end
end
