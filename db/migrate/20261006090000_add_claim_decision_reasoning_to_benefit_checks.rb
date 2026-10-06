class AddClaimDecisionReasoningToBenefitChecks < ActiveRecord::Migration[8.1]
  def change
    add_column :benefit_checks, :claim_decision_reasoning, :jsonb, default: []
  end
end
