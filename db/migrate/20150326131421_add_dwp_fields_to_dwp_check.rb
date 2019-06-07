class AddDwpFieldsToDwpCheck < ActiveRecord::Migration[5.2]
  def change
    add_column :dwp_checks, :dwp_result, :string
    add_column :dwp_checks, :dwp_id, :string
  end
end
