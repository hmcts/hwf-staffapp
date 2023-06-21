class CreateFeatureSwitchings < ActiveRecord::Migration[7.0]

  def change
    create_table :feature_switchings do |t|
      t.string :feature_key, null: false
      t.datetime :activation_time
      t.integer :office_id
      t.boolean :enabled, default: false

      t.timestamps
    end
    add_index :feature_switchings, :feature_key, unique: true
  end
end
