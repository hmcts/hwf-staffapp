class Users::InvitationsController < Devise::InvitationsController
  respond_to :html
  before_action :authenticate_user!
  before_action :build_role_list, only: [:new, :create]

  load_and_authorize_resource User, except: [:edit, :update]

  def new
    @user = User.new
    render :new
  end

  def create
    if user_not_admin_and_role_is_admin?
      raise 'Unpriviledged invitation error: Non-admin user is inviting an admin.'
    else
      self.resource = invite_resource
      respond_with resource, location: after_invite_path_for(resource)
    end
  end

  private

  def build_role_list
    if current_user.admin?
      @roles = User::ROLES
    else
      @roles = User::ROLES - %w[admin]
    end
  end

  def invite_resource
    resource_class.invite!(invite_params, current_inviter)
  end

  def invite_params
    params.require(:user).permit(:email, :role, :name, :office_id)
  end

  def user_not_admin_and_role_is_admin?
    !current_inviter.role.eql?('admin') && invite_params['role'].eql?('admin')
  end
end
