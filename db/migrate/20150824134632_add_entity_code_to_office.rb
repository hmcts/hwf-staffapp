class AddEntityCodeToOffice < ActiveRecord::Migration
  def change
    add_column :offices, :entity_code, :string
  end
end
