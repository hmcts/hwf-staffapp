class HomeController < ApplicationController
  def index
    if user_signed_in? && current_user.admin?
      @report_data = []
      Office.non_digital.each do |office|
        @report_data << {
          name: office.name,
          dwp_checks: DwpCheck.by_office_grouped_by_type(office.id).checks_by_day
        }
      end
    end
  end
end
