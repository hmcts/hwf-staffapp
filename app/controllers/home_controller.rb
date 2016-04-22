class HomeController < ApplicationController
  skip_after_action :verify_authorized

  def index
    manager_setup_progress
    load_graphs_for_admin
    load_waiting_applications
    @search_form = Forms::Search.new
    @state = DwpMonitor.new.state
  end

  def search
    @search_form = Forms::Search.new(search_params)

    online_application = search_and_return
    if online_application
      redirect_to(edit_online_application_path(online_application))
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

  def search_params
    params.require(:search).permit(:reference)
  end

  def search_and_return
    if @search_form.valid?
      begin
        OnlineApplication.find_by!(reference: @search_form.reference.upcase)
      rescue ActiveRecord::RecordNotFound
        @search_form.errors.add(:reference, :not_found)
        nil
      end
    end
  end
end
