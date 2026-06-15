module LoadApplications

  # Both methods return an ActiveRecord relation so callers can paginate
  # before any records are loaded.

  def self.waiting_for_evidence(user, filter = {}, sort = {})
    Query::WaitingForEvidence.new(user).find(filter: filter, sort: sort)
  end

  def self.waiting_for_part_payment(user, filter = {}, sort = {})
    Query::WaitingForPartPayment.new(user).find(filter: filter, sort: sort)
  end

  def self.load_users_last_applications(user)
    Query::LastUpdatedApplications.new(user).find(limit: 20)
  end

  def self.load_users_last_dwp_failed_applications(user)
    Query::LastDwpFailedApplications.new(user).find
  end

end
