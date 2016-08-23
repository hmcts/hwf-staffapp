class UpdateDecisionCost < ActiveRecord::Migration
  def up
    CorrectReturnedCosts.up!
  end
end
