class DecisionCostMigration
  def self.affected_records
    Application.where(decision_type: 'override', decision_cost: 0)
  end

  def self.run!
    affected_records.each do |application|
      application.update(decision_cost: application.detail.fee)
    end
  end
end
