class HomeController < ApplicationController
  skip_after_action :verify_authorized
  before_action :load_users_last_applications

  def index
    manager_setup_progress
    load_graphs_for_admin
    load_waiting_applications
    load_users_last_applications
    @online_search_form = Forms::Search.new
    @completed_search_form = Forms::Search.new
    @notification = Notification.first
  end

  def completed_search
    @online_search_form = Forms::Search.new
    @completed_search_form = Forms::Search.new
    @notification = Notification.first
    @search_results = search_and_return(:completed)

    if @search_results
      @search_results = paginate_search_results
    end

    render :index
  end

  def online_search
    search_or_render(:online) do
      @completed_search_form = Forms::Search.new
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

  def load_users_last_applications
    @last_updated_applications ||= Query::LastUpdatedApplications.new(current_user).find(limit: 20)
  end

  def assign_waiting_for_evidence
    @waiting_for_evidence = waiting_for_evidence.map do |application|
      Views::ApplicationList.new(application.evidence_check)
    end
  end

  def assign_waiting_for_part_payment
    @waiting_for_part_payment = waiting_for_part_payment.map do |application|
      Views::ApplicationList.new(application.part_payment)
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
      process_search(form, type)
    elsif type == :completed && form.reference.blank?
      form.errors.clear
      form.errors.add(:reference, blank_search_params_message)
      nil
    end
  end

  def process_search(form, type)
    search = ApplicationSearch.new(form.reference, current_user)
    search.send(type) || (form.errors.add(:reference, search.error_message) && nil)
  end

  def search_or_render(type)
    result = search_and_return(type)
    if result
      redirect_to(result)
    else
      yield if block_given?

      render :index
    end
  end

  def blank_search_params_message
    scope = 'activemodel.errors.models.forms/search.attributes.reference'
    I18n.t(:search_blank, scope: scope)
  end

  def paginate_search_results
    @search_results.
      paginate(page: params[:page]).
      # There is a bug when you try to order by assocations, this is a fix for it
      joins('LEFT JOIN applicants on applications.id = applicants.application_id').
      reorder('applications.created_at DESC, applicants.first_name ASC, applicants.last_name ASC')
  end
end
