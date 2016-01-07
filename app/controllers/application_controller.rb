class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include Pundit
  before_action :authenticate_user!
  after_action :verify_authorized
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorised

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

  def user_not_authorised
    flash[:alert] = t('unauthorized.flash')
    redirect_to(request.referrer || root_path)
  end
end
