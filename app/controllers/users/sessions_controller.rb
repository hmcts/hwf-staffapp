module Users
  class SessionsController < Devise::SessionsController
    skip_after_action :verify_authorized

    def new
      asd
      @notification = Notification.first
      @dwp_state = dwp_checker_state
      super
    end

    private

    def after_sign_out_path_for(*)
      new_user_session_path
    end
  end
end
