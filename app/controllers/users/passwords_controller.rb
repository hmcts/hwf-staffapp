module Users
  class PasswordsController < Devise::PasswordsController
    skip_after_action :verify_authorized

    def create
      if user.blank?
        flash[:notice] = I18n.t('.devise.failure.email_not_found')
        redirect_to new_user_password_path
      elsif !check_and_update_password_timestamp(user)
        alert_password_limit_and_redirect
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

    def check_and_update_password_timestamp(user)
      last_check_timestamp = user&.last_password_reset_check_at
      if last_check_timestamp.nil? || Time.now.utc - last_check_timestamp > 1.minute
        user.update(last_password_reset_check_at: Time.now.utc)
      end
    end

    def alert_password_limit_and_redirect
      flash[:notice] = I18n.t('.devise.passwords.password_limit_reset')
      respond_with({}, location: after_sending_reset_password_instructions_path_for(:user))
    end
  end
end
