class OfficePolicy < BasePolicy
  def index?
    !mi?
  end

  def show?
    !mi?
  end

  def new?
    admin?
  end

  def create?
    admin?
  end

  def edit?
    admin? || (manager? && same_office?)
  end

  def update?
    admin? || (manager? && same_office?)
  end

  private

  def same_office?
    @record == @user.office
  end
end
