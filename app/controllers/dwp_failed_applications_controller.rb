class DwpFailedApplicationsController < ApplicationController
  skip_after_action :verify_authorized, only: :index

  def index
    authorize :application unless current_user.admin?
    @ready_to_process = ready_to_process?
    @list ||= LoadApplications.load_users_last_dwp_failed_applications(current_user)
  end

  private

  def ready_to_process?
    DwpWarning::STATES[:offline] != dwp_checker_state
  end
end
