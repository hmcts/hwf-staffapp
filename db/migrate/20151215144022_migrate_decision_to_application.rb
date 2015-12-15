class MigrateDecisionToApplication < ActiveRecord::Migration
  def up
    DecisionMigration.new.run!
  end

  def down
  end
end
