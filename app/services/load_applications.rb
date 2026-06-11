module LoadApplications

  # Both methods return an ActiveRecord relation so callers can paginate
  # before any records are loaded.

  # rubocop:disable Metrics/ParameterLists
  def self.waiting_for_evidence(user, filter = {}, order = {}, show_form_name = false, show_court_fee = false)
    Query::WaitingForEvidence.new(user).find(show_form_name, show_court_fee,
                                             filter, order['order_choice'])
  end

  def self.waiting_for_part_payment(user, filter = {}, order = {}, show_form_name = false, show_court_fee = false)
    Query::WaitingForPartPayment.new(user).find(show_form_name, show_court_fee,
                                                filter, order['order_choice'])
  end
  # rubocop:enable Metrics/ParameterLists

  def self.load_users_last_applications(user)
    Query::LastUpdatedApplications.new(user).find(limit: 20)
  end

  def self.load_users_last_dwp_failed_applications(user)
    Query::LastDwpFailedApplications.new(user).find
  end

end
