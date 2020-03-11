module Users
  class InvitationsController < Devise::InvitationsController
    respond_to :html
    before_action :build_invite_lookup_lists, only: [:new, :create]

    skip_before_action :authenticate_user!, only: [:edit, :update, :destroy]
    skip_after_action :verify_authorized, only: [:edit, :update, :destroy]

    def new
      @user = User.new
      authorize @user

      render :new
    end

    def create
      authorize user_for_authorization
      if @user.deleted?
        flash[:alert] = t('devise.invitations.user_exists', email: Settings.mail.tech_support)
        render :new
      else
        super
      end
    end

    private

    def build_invite_lookup_lists
      @roles = if current_user.admin?
                 User::ROLES
               else
                 ['user', 'manager', 'reader']
               end
      @offices = Office.all.order(:name)
    end

    def invite_params
      params.require(:user).permit(:email, :role, :name, :office_id)
    end

    def user_for_authorization
      @user ||= deleted_user_exists? || User.new(invite_params)
    end

    def deleted_user_exists?
      User.with_deleted.find_by(email: invite_params[:email].downcase)
    end
  end
end
