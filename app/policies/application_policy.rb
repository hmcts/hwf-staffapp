class ApplicationPolicy < BasePolicy
  def index?
    !admin?
  end

  def show?
    !admin? && same_office?
  end

  class Scope < BasePolicy::Scope
  end

  private

  def same_office?
    @record.office == @user.office
  end
end
