class ApplicationPolicy < BasePolicy
  def new?
    !admin?
  end

  def create?
    !admin? && same_office?
  end

  def index?
    !admin?
  end

  def show?
    !admin? && same_office?
  end

  def update?
    !admin? && same_office?
  end

  class Scope < BasePolicy::Scope
    def resolve
      if admin?
        @scope.none
      else
        @scope.where(office: @user.office)
      end
    end
  end
end
