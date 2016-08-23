class CorrectReturnedCosts
  def self.affected_records
    Application.where(decision: 'none').where('decision_cost > 0')
  end

  def self.up!
    affected_records.each do |application|
      application.update(decision_cost: 0)
    end
  end
end
