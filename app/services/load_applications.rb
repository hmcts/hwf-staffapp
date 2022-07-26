module LoadApplications

  def self.waiting_for_evidence(user, filter = {})
    waiting_for_evidence_query = Query::WaitingForEvidence.new(user).find(filter)
    waiting_for_evidence_query.map do |application|
      Views::ApplicationList.new(application.evidence_check)
    end
  end

  def self.waiting_for_part_payment(user, filter = {})
    waiting_for_part_payment_query = Query::WaitingForPartPayment.new(user).find(filter)
    waiting_for_part_payment_query.map do |application|
      Views::ApplicationList.new(application.part_payment)
    end
  end

  def self.load_users_last_applications(user)
    Query::LastUpdatedApplications.new(user).find(limit: 20)
  end

  def self.load_users_last_dwp_failed_applications(user)
    Query::LastDwpFailedApplications.new(user).find
  end

end
