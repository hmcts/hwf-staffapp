class HomeController < ApplicationController
  before_action :load_dwp_data, only: [:index], if: 'user_signed_in? && current_user.manager?'

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

private

  def load_dwp_data
    @dwpchecks = DwpCheck.
                 by_office(current_user.office_id).
                 page(params[:page]).
                 order('created_at DESC')
  end
end
