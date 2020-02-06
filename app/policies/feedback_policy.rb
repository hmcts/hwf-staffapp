class FeedbackPolicy < BasePolicy
  def index?
    admin?
  end

  def new?
    staff_or_manager? || reader?
  end

  def create?
    (staff_or_manager? || reader?) && same_user? && same_office?
  end

  private

  def same_user?
    @record.user == @user
  end
end
