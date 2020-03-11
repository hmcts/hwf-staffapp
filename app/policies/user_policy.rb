class UserPolicy < BasePolicy
  def index?
    manager? || admin?
  end

  def invite?
    admin?
  end

  def list_deleted?
    admin?
  end

  def restore?
    admin?
  end

  def show?
    user_themselves? || (manager? && same_office?) || admin?
  end

  def new?
    manager? || admin?
  end

  def create?
    (manager? && same_office? && allowed_role?) || admin?
  end

  def edit?
    user_themselves? || (manager? && same_office?) || admin?
  end

  def update?
    (user_themselves? && allowed_role?) ||
      manager_update? ||
      admin?
  end

  def destroy?
    !user_themselves? && ((manager? && same_office?) || admin?)
  end

  def edit_password?
    user_themselves?
  end

  def edit_office?
    return false if reader?
    user_themselves? || manager? || admin?
  end

  def edit_jurisdiction?
    return false if reader?
    user_themselves? || manager? || admin?
  end

  alias update_password? edit_password?

  class Scope < BasePolicy::Scope
    def resolve
      if admin?
        @scope.all
      elsif manager?
        @scope.where(office: @user.office).where(role: [:user, :manager])
      else
        @scope.none
      end
    end
  end

  def allowed_role
    allowed_role_changes[@user.role]
  end

  private

  def allowed_role_changes
    {
      'user' => ['user'],
      'manager' => ['user', 'manager', 'reader'],
      'admin' => ['user', 'manager', 'admin', 'mi', 'reader'],
      'mi' => ['mi'],
      'reader' => ['reader']
    }
  end

  def user_themselves?
    @record == @user
  end

  def allowed_role?
    allowed_role_changes[@user.role].include?(@record.role)
  end

  def upgrade_from_user_role?
    @record.role != 'user'
  end

  def manager_update?
    manager? &&
      ((same_office? && allowed_role?) || (!same_office? && !upgrade_from_user_role?))
  end
end
