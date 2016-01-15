module Users
  class RegistrationsController < Devise::RegistrationsController

    before_action :authorize_for_current_user

    def edit
      super
    end

    def update
      if account_update_params[:password].present?
        super
      else
        error_message = t('activerecord.errors.models.user.attributes.password.blank')
        resource.errors.add(:password, error_message)
        respond_with resource
      end
    end

    private

    def their_own?
      current_user.id.eql?(params[:id].to_i)
    end

    def authorize_for_current_user
      authorize current_user if their_own?
    end
  end
end
