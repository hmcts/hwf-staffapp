class CreateReasons < ActiveRecord::Migration[5.2]
  def change
    create_table :reasons do |t|
      t.string :explanation
      t.references :evidence_check, index: true, foreign_key: true
    end
  end
end
