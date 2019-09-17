class CompleteDecisionCost < ActiveRecord::Migration[5.2]
  def up
    DecisionCostMigration.run!
  end
end
