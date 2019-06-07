class CreateSavings < ActiveRecord::Migration[5.2]

  def change
    create_table :savings do |t|
      t.references :application, index: true, null: false
      t.decimal :min_threshold
      t.boolean :min_threshold_exceeded
      t.decimal :max_threshold
      t.boolean :max_threshold_exceeded
      t.decimal :amount
      t.boolean :passed
      t.decimal :fee_threshold
      t.boolean :over_61
      t.timestamps null: false
    end

    add_foreign_key :savings, :applications

  end
end
