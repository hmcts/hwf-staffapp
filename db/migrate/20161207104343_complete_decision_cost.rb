class CompleteDecisionCost < ActiveRecord::Migration
  def up
    DecisionCostMigration.run!
  end
end
