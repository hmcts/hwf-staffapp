class BusinessEntityPolicy < BasePolicy
  def index?
    admin?
  end
end
