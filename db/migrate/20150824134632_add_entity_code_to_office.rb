class AddEntityCodeToOffice < ActiveRecord::Migration[5.2]
  def change
    add_column :offices, :entity_code, :string
  end
end
