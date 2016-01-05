class ReportPolicy < BasePolicy
  def index?
    admin?
  end

  def show?
    index?
  end
end
