module Users
  class RegistrationsController < Devise::RegistrationsController
    def update
      if account_update_params[:password].present?
        super
      else
        error_message = t('activerecord.errors.models.user.attributes.password.blank')
        resource.errors.add(:password, error_message)
        respond_with resource
      end
    end
  end
end
