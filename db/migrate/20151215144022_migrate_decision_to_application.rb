class MigrateDecisionToApplication < ActiveRecord::Migration[5.2]
  def up
    DecisionMigration.new.run!
  end

  def down
  end
end
