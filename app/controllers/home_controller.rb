class HomeController < ApplicationController
  def index
    if user_signed_in?
      @checks_by_day = DwpCheck.by_office(current_user.office_id).checks_by_day
    end
  end
end
