class OnlineApplicationPolicy < BasePolicy
  def edit?
    staff_or_manager?
  end
end
