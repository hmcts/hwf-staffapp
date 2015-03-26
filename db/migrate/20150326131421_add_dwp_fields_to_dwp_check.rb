class AddDwpFieldsToDwpCheck < ActiveRecord::Migration
  def change
    add_column :dwp_checks, :dwp_result, :string
    add_column :dwp_checks, :dwp_id, :string
  end
end
