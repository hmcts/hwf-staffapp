class HomeController < ApplicationController
  before_action :load_dwp_data, only: [:index], if: 'user_signed_in? && current_user.manager?'

  def index
    if user_signed_in?
      @checks_by_day = DwpCheck.by_office_grouped_by_type(current_user.office_id).checks_by_day
      @r2_checks = R2Calculator.by_office_grouped_by_type(current_user.office_id).checks_by_day
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
