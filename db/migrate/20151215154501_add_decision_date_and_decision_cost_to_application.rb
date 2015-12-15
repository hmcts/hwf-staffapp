class AddDecisionDateAndDecisionCostToApplication < ActiveRecord::Migration
  def change
    change_table :applications do |t|
      t.datetime :decision_date, null: true, index: true
      t.decimal :decision_cost, null: true
    end

    reversible do |dir|
      dir.up do
        DecisionDateAndCostMigration.new.run!
      end
    end
  end
end
