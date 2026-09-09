class CreateAppeals < ActiveRecord::Migration[8.1]
  def change
    create_table :appeals do |t|
      t.references :application, null: false, foreign_key: true
      t.references :completed_by, null: false, foreign_key: { to_table: :users }
      t.boolean :correct, null: false, default: false

      t.timestamps
    end
  end
end
