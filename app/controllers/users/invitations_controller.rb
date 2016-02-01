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
      user_for_authorisation
      authorize user_for_authorisation
      if user_for_authorisation.deleted?
        flash[:alert] = t('devise.invitations.user_exists', email: Settings.mail.tech_support)
        @user = user_for_authorisation
        render :new
      else
        super
      end
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

    def user_for_authorisation
      deleted_user_exists? || User.new(invite_params)
    end

    def deleted_user_exists?
      User.with_deleted.find_by(email: invite_params[:email])
    end
  end
end
