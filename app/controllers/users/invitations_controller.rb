class Users::InvitationsController < Devise::InvitationsController
  respond_to :html

  private

  def invite_resource
    resource_class.invite!(invite_params, current_inviter)
  end

  def invite_params
    params.require(:user).permit(:email, :role)
  end

end