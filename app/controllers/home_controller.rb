class HomeController < ApplicationController
  skip_after_action :verify_authorized
  before_action :load_users_last_applications

  def index
    manager_setup_progress
    load_graphs_for_admin
    load_waiting_applications
    load_defaults
  end

  def completed_search
    load_defaults
    @search_results = search_and_return(:completed)

    render :index
  end

  def online_search
    result = online_process_search
    if result
      redirect_to(result)
    else
      load_defaults
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

  def load_users_last_applications
    @last_updated_applications ||= LoadApplications.load_users_last_applications(current_user)
  end

  def assign_waiting_for_evidence
    @waiting_for_evidence = LoadApplications.waiting_for_evidence(current_user)
  end

  def assign_waiting_for_part_payment
    @waiting_for_part_payment = LoadApplications.waiting_for_part_payment(current_user)
  end

  def search_params(type)
    params.require(:"#{type}_search").permit(:reference)
  end

  def search_and_return(type)
    form = instance_variable_set("@#{type}_search_form", Forms::Search.new(search_params(type)))

    process_search(form) if ready_to_search?(form)
  end

  def ready_to_search?(form)
    return true if form.reference.present?
    form.errors.add(:reference, blank_search_params_message)
    nil
  end

  def process_search(form)
    @search = ApplicationSearch.new(form.reference, current_user)
    results = (@search.call || (form.errors.add(:reference, @search.error_message) && nil))
    paginate_search_results if results
  end

  def online_process_search
    @online_search_form = Forms::Search.new(search_params(:online))

    if @online_search_form.valid?
      @search = OnlineApplicationSearch.new(@online_search_form.reference, current_user)
      @search.online || (@online_search_form.errors.add(:reference, @search.error_message) && nil)
    end
  end

  def blank_search_params_message
    scope = 'activemodel.errors.models.forms/search.attributes.reference'
    I18n.t(:search_blank, scope: scope)
  end

  def paginate_search_results
    @sort_by = params['sort_by']
    @sort_to = params['sort_to']
    pagination_params = { sort_to: @sort_to, sort_by: @sort_by, page: params[:page] }
    @search.paginate_search_results(pagination_params)
  end

  def load_defaults
    @online_search_form ||= Forms::Search.new
    @completed_search_form ||= Forms::Search.new
    @notification = Notification.first
  end
end
