class HomeController < ApplicationController
  before_action :authenticate_user!, only: [:index]

  def index
    manager_setup = ManagerSetup.new(current_user, session)
    manager_setup.finish! if manager_setup.in_progress?
    if current_user.admin?
      load_graph_data
      @total_type_count = BenefitCheck.group(:dwp_result).count
      @time_of_day_count = BenefitCheck.group_by_hour_of_day("created_at", format: '%l %p').count
    end
  end

  private

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
