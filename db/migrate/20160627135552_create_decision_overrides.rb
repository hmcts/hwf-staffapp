class CreateDecisionOverrides < ActiveRecord::Migration
  def change
    create_table :decision_overrides do |t|
      t.references :user, index: true, foreign_key: true
      t.references :application, index: true, foreign_key: true
      t.string :reason

      t.timestamps null: false
    end
  end
end
