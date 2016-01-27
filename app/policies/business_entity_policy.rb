class BusinessEntityPolicy < BasePolicy
  def index?
    admin_or_mi?
  end

  def new?
    admin_or_mi?
  end

  def create?
    admin_or_mi?
  end

  def edit?
    admin_or_mi?
  end

  def update?
    admin_or_mi?
  end

  def deactivate?
    admin_or_mi?
  end

  def confirm_deactivate?
    admin_or_mi?
  end
end
