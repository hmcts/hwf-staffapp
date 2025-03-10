class CreateDevNotes < ActiveRecord::Migration[8.0]
  def change
    create_table :dev_notes do |t|
      t.string :note
      t.references :notable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
