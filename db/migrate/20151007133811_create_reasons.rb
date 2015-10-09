class CreateReasons < ActiveRecord::Migration
  def change
    create_table :reasons do |t|
      t.string :explanation
      t.references :evidence_check, index: true, foreign_key: true
    end
  end
end
