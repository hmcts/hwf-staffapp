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

    # rubocop:disable Metrics/AbcSize
    def send_notification_and_redirect
      if user.send_reset_password_instructions && check_reset_timestamp(user)
        flash[:notice] = I18n.t('.devise.passwords.send_instructions')
        respond_with({}, location: after_sending_reset_password_instructions_path_for(:user))
      elsif user.send_reset_password_instructions && reset_time_difference(user) < 1.minute
        flash[:notice] = I18n.t('.devise.passwords.password_limit_reset')
        redirect_to new_user_password_path
      else
        flash[:notice] = I18n.t('.devise.failure.not_sent')
        redirect_to new_user_password_path
      end
    end
    # rubocop:enable Metrics/AbcSize

    def user
      email = params[:user][:email].strip.downcase
      @user ||= User.find_by(email: email)
    end

    def check_reset_timestamp(user)
      last_check_timestamp = user&.last_password_reset_check_at
      if last_check_timestamp.nil? || Time.now.utc - last_check_timestamp > 1.minute
        user.update(last_password_reset_check_at: Time.now.utc)
        true
      else
        false
      end
    end

    def reset_time_difference(user)
      Time.now.utc - user.reset_password_sent_at
    end

  end
end
