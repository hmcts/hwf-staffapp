class AddFieldsToDwpCheck < ActiveRecord::Migration
  def change
    add_column :dwp_checks, :our_api_token, :string
    add_reference :dwp_checks, :office, index: true, foreign_key: true
  end
end
