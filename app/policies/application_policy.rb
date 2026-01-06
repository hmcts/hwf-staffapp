class ApplicationPolicy < BasePolicy
  def new?
    staff_or_manager?
  end

  def create?
    staff_or_manager? && same_office?
  end

  def index?
    staff_or_manager? || reader? || admin?
  end

  def show?
    return true if admin?
    (staff_or_manager? || reader?) && same_office?
  end

  def flow?
    show?
  end

  def update?
    staff_or_manager? && same_office?
  end

  def approve?
    staff_or_manager? && same_office?
  end

  def approve_save?
    staff_or_manager? && same_office?
  end

  class Scope < BasePolicy::Scope
    def resolve
      if staff_or_manager? || reader?
        @scope.where(office: @user.office)
      else
        @scope.none
      end
    end
  end
end
