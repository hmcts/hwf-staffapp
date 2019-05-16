class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include Pundit
  before_action :authenticate_user!
  before_action :set_paper_trail_whodunnit
  before_action :track_office_id, if: :user_signed_in?
  after_action :verify_authorized
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def after_invite_path_for(*)
    users_path
  end

  def after_sign_in_path_for(resource)
    manager_setup = ManagerSetup.new(resource, session)
    if manager_setup.setup_profile?
      manager_setup.start!
      edit_user_path(current_user)
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

  def add_datalayer_event(name, data)
    event = GtmOnRails::DataLayer::Event.new(name, data)
    data_layer.push(event)
  end

  def track_application(app, default = 'NA')
    data = {
      medium: app.medium || default,
      type: app.application_type || default,
      jurisdiction_id: app.detail.jurisdiction_id || default
    }
    add_datalayer_event('Application tracking', data)
  end

  def track_online_application(app)
    data = {
      medium: 'digital',
      type: 'TBC',
      jurisdiction_id: app.jurisdiction_id || 'TBC'
    }
    add_datalayer_event('Application tracking', data)
  end

  def track_office_id
    add_datalayer_event('Office id', office_id: current_user.office_id)
  end
end
