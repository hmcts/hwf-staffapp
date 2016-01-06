class UserPolicy < BasePolicy
  def index?
    manager? || admin?
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
    (manager? && same_office? && !setting_to_admin_role?) || admin?
  end

  def edit?
    user_themselves? || (manager? && same_office?) || admin?
  end

  def update?
    (user_themselves? && !upgrade_own_role?) ||
      manager_update? ||
      admin?
  end

  def destroy?
    !user_themselves? && ((manager? && same_office?) || admin?)
  end

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

  private

  def roles_in_order
    %w[user manager admin]
  end

  def user_themselves?
    @record == @user
  end

  def upgrade_own_role?
    roles_in_order.index(@record.role) > roles_in_order.index(@user.role)
  end

  def upgrade_from_user_role?
    @record.role != 'user'
  end

  def setting_to_admin_role?
    @record.role == 'admin'
  end

  def same_office?
    @record.office == @user.office
  end

  def manager_update?
    manager? &&
      ((same_office? && !setting_to_admin_role?) || (!same_office? && !upgrade_from_user_role?))
  end
end
