module Users
  class PasswordsController < Devise::PasswordsController
    skip_after_action :verify_authorized

    def create
      if user.blank?
        flash[:notice] = I18n.t('.devise.failure.email_not_found')
        redirect_to new_user_password_path
      else
        set_reset_password_token
        send_notification_and_redirect
      end
    end

    private

    def send_notification_and_redirect
      notify = NotifyMailer.password_reset(user, reset_link)

      if notify.deliver
        flash[:notice] = I18n.t('.devise.passwords.send_instructions')
        respond_with({}, location: after_sending_reset_password_instructions_path_for(:user))
      else
        flash[:notice] = I18n.t('.devise.failure.not_sent')
        redirect_to new_user_password_path
      end
    end

    def set_reset_password_token
      raw, enc = Devise.token_generator.generate(User, :reset_password_token)

      user.reset_password_token   = enc
      user.reset_password_sent_at = Time.now.utc
      user.save(validate: false)
      @token = raw
    end

    def user
      @user ||= User.find_by(email: params[:user][:email])
    end

    def reset_link
      edit_user_password_url(reset_password_token: @token)
    end

  end
end
