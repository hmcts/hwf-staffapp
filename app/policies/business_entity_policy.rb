class BusinessEntityPolicy < BasePolicy
  def index?
    admin?
  end

  def new?
    admin?
  end

  def edit?
    admin?
  end

  def update?
    admin?
  end
end
