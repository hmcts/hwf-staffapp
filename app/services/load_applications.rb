module LoadApplications

  def self.waiting_for_evidence(user)
    waiting_for_evidence_query = Query::WaitingForEvidence.new(user).find
    waiting_for_evidence_query.map do |application|
      Views::ApplicationList.new(application.evidence_check)
    end
  end

  def self.waiting_for_part_payment(user)
    waiting_for_part_payment_query = Query::WaitingForPartPayment.new(user).find
    waiting_for_part_payment_query.map do |application|
      Views::ApplicationList.new(application.part_payment)
    end
  end

  def self.load_users_last_applications(user)
    Query::LastUpdatedApplications.new(user).find(limit: 20)
  end

end
