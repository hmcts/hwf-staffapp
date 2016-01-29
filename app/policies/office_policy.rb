class OfficePolicy < BasePolicy
  def index?
    admin_or_mi?
  end

  def show?
    admin_or_mi? || (staff_or_manager? && same_office?)
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
