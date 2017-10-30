module Users
  class ConfirmationsController < Devise::ConfirmationsController
    skip_after_action :verify_authorized, only: [:show]

    def show
      self.resource = resource_class.confirm_by_token(params[:confirmation_token])
      yield resource if block_given?

      if resource.errors.empty?
        set_flash_message!(:notice, :confirmed)
      else
        set_flash_message!(:alert, :error)
      end
      redirect_to after_confirmation_path
    end

    private

    def after_confirmation_path
      if current_user
        user_path(current_user)
      else
        new_user_session_path
      end
    end
  end
end
