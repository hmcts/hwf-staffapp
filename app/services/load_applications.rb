module LoadApplications

  # rubocop:disable Metrics/ParameterLists
  def self.waiting_for_evidence(user, filter = {}, order = {}, show_form_name = false, show_court_fee = false)
    waiting_for_evidence_query = Query::WaitingForEvidence.new(user).find(show_form_name, show_court_fee,
                                                                          filter, order['order_choice'])
    waiting_for_evidence_query.map do |application|
      Views::ApplicationList.new(application.evidence_check)
    end
  end

  def self.waiting_for_part_payment(user, filter = {}, order = {}, show_form_name = false, show_court_fee = false)
    waiting_for_part_payment_query = Query::WaitingForPartPayment.new(user).find(show_form_name, show_court_fee,
                                                                                 filter, order['order_choice'])
    waiting_for_part_payment_query.map do |application|
      Views::ApplicationList.new(application.part_payment)
    end
  end
  # rubocop:enable Metrics/ParameterLists

  def self.load_users_last_applications(user)
    Query::LastUpdatedApplications.new(user).find(limit: 20)
  end

  def self.load_users_last_dwp_failed_applications(user)
    Query::LastDwpFailedApplications.new(user).find
  end

end
