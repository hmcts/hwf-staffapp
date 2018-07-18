class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include Pundit
  before_action :authenticate_user!
  before_action :set_paper_trail_whodunnit
  after_action :verify_authorized
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def after_invite_path_for(*)
    users_path
  end

  def after_sign_in_path_for(resource)
    manager_setup = ManagerSetup.new(resource, session)
    if manager_setup.setup_office?
      manager_setup.start!
      edit_office_path(current_user.office)
    else
      root_path
    end
  end

  def user_not_authorized
    flash[:alert] = t('unauthorized.flash')
    redirect_to(request.referer || root_path)
  end

  def set_cache_headers
    response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 3.hours.ago.to_formatted_s(:rfc822)
  end

  def dwp_checker_state
    return DwpMonitor.new.state if DwpWarning.use_default_check?
    DwpWarning.last.check_state
  end
end
