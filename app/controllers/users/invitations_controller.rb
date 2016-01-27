module Users
  class InvitationsController < Devise::InvitationsController
    respond_to :html
    before_action :build_role_list, only: [:new, :create]

    skip_before_action :authenticate_user!, only: [:edit, :update, :destroy]
    skip_after_action :verify_authorized, only: [:edit, :update, :destroy]

    def new
      @user = User.new
      authorize @user

      render :new
    end

    def create
      user_for_authorisation = User.new(invite_params)
      authorize user_for_authorisation

      super
    end

    private

    def build_role_list
      if current_user.admin?
        @roles = User::ROLES
      else
        @roles = %w[user manager]
      end
    end

    def invite_params
      params.require(:user).permit(:email, :role, :name, :office_id)
    end
  end
end
