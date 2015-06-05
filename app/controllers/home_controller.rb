class HomeController < ApplicationController
  before_action :load_dwp_data, only: [:index], if: 'user_signed_in? && current_user.manager?'

  def index
  end

private

  def load_dwp_data
    @dwpchecks = DwpCheck.
                 by_office(current_user.office_id).
                 page(params[:page]).
                 order('created_at DESC')
  end
end
