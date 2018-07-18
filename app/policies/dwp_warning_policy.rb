class DwpWarningPolicy < BasePolicy
  def edit?
    admin?
  end

  def update?
    admin?
  end
end
