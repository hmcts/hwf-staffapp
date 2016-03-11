class OnlineApplicationPolicy < BasePolicy
  def edit?
    staff_or_manager?
  end

  def update?
    staff_or_manager?
  end

  def show?
    staff_or_manager?
  end
end
