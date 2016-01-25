class ApplicationPolicy < BasePolicy
  def new?
    staff_or_manager?
  end

  def create?
    staff_or_manager? && same_office?
  end

  def index?
    staff_or_manager?
  end

  def show?
    staff_or_manager? && same_office?
  end

  def update?
    staff_or_manager? && same_office?
  end

  class Scope < BasePolicy::Scope
    def resolve
      if staff_or_manager?
        @scope.where(office: @user.office)
      else
        @scope.none
      end
    end
  end
end
