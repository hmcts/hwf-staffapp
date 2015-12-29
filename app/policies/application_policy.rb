class ApplicationPolicy < BasePolicy
  def index?
    !admin?
  end

  def show?
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

  private

  def same_office?
    @record.office == @user.office
  end
end
