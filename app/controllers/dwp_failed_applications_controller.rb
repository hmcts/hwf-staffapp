class DwpFailedApplicationsController < ApplicationController
  skip_after_action :verify_authorized, only: :index

  def index
    authorize :application unless current_user.admin?

    @list ||= LoadApplications.load_users_last_dwp_failed_applications(current_user)
  end

end
