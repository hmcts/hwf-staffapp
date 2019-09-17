class UpdateDecisionCost < ActiveRecord::Migration[5.2]
  def up
    CorrectReturnedCosts.up!
  end
end
