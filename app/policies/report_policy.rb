class ReportPolicy < BasePolicy
  def index?
    admin?
  end

  def show?
    index?
  end

  def graphs?
    admin?
  end
end
