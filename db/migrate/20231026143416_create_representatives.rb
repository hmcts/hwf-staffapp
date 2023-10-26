class CreateRepresentatives < ActiveRecord::Migration[7.0]
  def change
    create_table :representatives do |t|
      t.integer "application_id", null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :organisation

      t.timestamps
    end
  end
end
