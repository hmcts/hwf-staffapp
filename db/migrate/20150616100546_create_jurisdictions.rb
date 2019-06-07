class CreateJurisdictions < ActiveRecord::Migration[5.2]
  def change
    create_table :jurisdictions do |t|
      t.string :name
      t.string :abbr
      t.boolean :active

      t.timestamps null: false
    end
  end
end
