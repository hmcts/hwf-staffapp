class ReportPolicy < BasePolicy
  def index?
    admin? || mi?
  end

  def show?
    admin? || mi?
  end

  def graphs?
    admin?
  end

  def public?
    admin?
  end
end
