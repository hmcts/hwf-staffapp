module Users
  class PasswordsController < Devise::PasswordsController
    skip_after_action :verify_authorized

    def create
      if user.blank?
        flash[:notice] = I18n.t('.devise.failure.email_not_found')
        redirect_to new_user_password_path
      else
        send_notification_and_redirect
      end
    end

    private

    def send_notification_and_redirect
      if user.send_reset_password_instructions
        flash[:notice] = I18n.t('.devise.passwords.send_instructions')
        respond_with({}, location: after_sending_reset_password_instructions_path_for(:user))
      else
        flash[:notice] = I18n.t('.devise.failure.not_sent')
        redirect_to new_user_password_path
      end
    end

    def user
      email = params[:user][:email].strip.downcase
      @user ||= User.find_by(email: email)
    end

  end
end
