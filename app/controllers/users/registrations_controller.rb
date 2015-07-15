class Users::RegistrationsController < Devise::RegistrationsController
  def update
    if account_update_params[:password].present?
      super
    else
      resource.errors.add(:password, t('activerecord.errors.models.user.attributes.password.blank'))
      respond_with resource
    end
  end
end
