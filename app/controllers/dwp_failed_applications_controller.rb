class DwpFailedApplicationsController < ApplicationController

  def index
    authorize :application

    @list ||= LoadApplications.load_users_last_dwp_failed_applications(current_user)
  end

end
