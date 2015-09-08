class CreateReferences < ActiveRecord::Migration
  def change
    create_table :references do |t|
      t.binary :secure_random, null: false
      t.string :reference_hash, index: true, null: false
      t.references :application, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
