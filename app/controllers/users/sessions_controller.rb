module Users
  class SessionsController < Devise::SessionsController
    skip_after_action :verify_authorized

    def new
      @notification = Notification.first
      super
    end
  end
end
