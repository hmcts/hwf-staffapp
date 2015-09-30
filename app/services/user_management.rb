class UserManagement

  def initialize(current_user, user)
    @current_user = current_user
    @user = user
  end

  def deletion_permitted?
    @current_user.elevated? && !user_themselves?
  end

  def user_themselves?
    @current_user.id == @user.id
  end

  def transferred?
    @current_user.manager? && not_their_office?
  end

  def admin_manager_or_user_themselves?
    @current_user.admin? || manages_user? || user_themselves?
  end

  def manager_cant_escalate_to_admin?(role)
    @current_user.admin? || manages_user? && role != 'admin'
  end

  private

  def manages_user?
    @current_user.manager? && @current_user.office == @user.office
  end

  def not_their_office?
    @current_user.office != @user.office
  end
end
