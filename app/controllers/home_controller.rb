class HomeController < ApplicationController
  before_action :authenticate_user!, only: [:index]

  def index
    manager_setup_progress
    load_graphs_for_admin
    load_waiting_applications
  end

  private

  def manager_setup_progress
    manager_setup = ManagerSetup.new(current_user, session)
    manager_setup.finish! if manager_setup.in_progress?
  end

  def load_graphs_for_admin
    if current_user.admin?
      load_graph_data
      @total_type_count = BenefitCheck.group(:dwp_result).count
      @time_of_day_count = BenefitCheck.group_by_hour_of_day("created_at", format: '%l %p').count
    end
  end

  def load_waiting_applications
    unless current_user.admin?
      assign_waiting_for_evidence if evidence_check_enabled?
      assign_waiting_for_payment if payment_enabled?
    end
  end

  def assign_waiting_for_evidence
    @waiting_for_evidence = waiting_for_evidence.map do |application|
      Views::ProcessingDetails.new(application.evidence_check)
    end
  end

  def assign_waiting_for_payment
    @waiting_for_payment = waiting_for_payment.map do |application|
      Views::ProcessingDetails.new(application.payment)
    end
  end

  def waiting_for_evidence
    Query::WaitingForEvidence.new(current_user).find
  end

  def waiting_for_payment
    Query::WaitingForPayment.new(current_user).find
  end

  def load_graph_data
    @report_data = []
    Office.non_digital.each do |office|
      @report_data << {
        name: office.name,
        dwp_checks: BenefitCheck.by_office_grouped_by_type(office.id).checks_by_day
      }
    end
  end
end
