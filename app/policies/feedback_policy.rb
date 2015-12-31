class FeedbackPolicy < BasePolicy
  def index?
    admin?
  end

  def new?
    staff? || manager?
  end

  def create?
    new? && same_user? && same_office?
  end

  private

  def same_user?
    @record.user == @user
  end

  def same_office?
    @record.office == @user.office
  end
end
