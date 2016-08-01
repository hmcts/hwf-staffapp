class HomeController < ApplicationController
  skip_after_action :verify_authorized

  def index
    manager_setup_progress
    load_graphs_for_admin
    load_waiting_applications
    @online_search_form = Forms::Search.new
    @state = DwpMonitor.new.state
  end

  def online_search
    result = search_and_return(:online)
    if result
      redirect_to(result)
    else
      load_waiting_applications
      @state = DwpMonitor.new.state
      render :index
    end
  end

  helper_method def dwp_maintenance?
    Time.zone.now < Time.zone.parse('24/04/2016 20:00:00')
  end

  private

  def manager_setup_progress
    manager_setup = ManagerSetup.new(current_user, session)
    manager_setup.finish! if manager_setup.in_progress?
  end

  def load_graphs_for_admin
    if current_user.admin?
      @total_type_count = BenefitCheck.group(:dwp_result).count
      @time_of_day_count = BenefitCheck.group_by_hour_of_day("created_at", format: '%l %p').count
    end
  end

  def load_waiting_applications
    unless current_user.admin?
      assign_waiting_for_evidence
      assign_waiting_for_part_payment
    end
  end

  def assign_waiting_for_evidence
    @waiting_for_evidence = waiting_for_evidence.map do |application|
      Views::ProcessingDetails.new(application.evidence_check)
    end
  end

  def assign_waiting_for_part_payment
    @waiting_for_part_payment = waiting_for_part_payment.map do |application|
      Views::ProcessingDetails.new(application.part_payment)
    end
  end

  def waiting_for_evidence
    Query::WaitingForEvidence.new(current_user).find
  end

  def waiting_for_part_payment
    Query::WaitingForPartPayment.new(current_user).find
  end

  def search_params(type)
    params.require(:"#{type}_search").permit(:reference)
  end

  def search_and_return(type)
    form = instance_variable_set("@#{type}_search_form", Forms::Search.new(search_params(type)))
    if form.valid?
      search = ApplicationSearch.new(form.reference, current_user)
      search.online || (form.errors.add(:reference, search.error_message) && nil)
    end
  end
end
