class Users::InvitationsController < Devise::InvitationsController
  respond_to :html
  before_action :build_role_list, only: [:new, :create]

  load_and_authorize_resource User, except: [:edit, :update]

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
      @roles = User::ROLES - %w[admin]
    end
  end

  def invite_params
    params.require(:user).permit(:email, :role, :name, :office_id)
  end
end
