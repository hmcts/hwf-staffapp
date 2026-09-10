# Records the single staff review of benefit evidence received after a benefit
# application was processed as not eligible, and sets the decision from that
# review. The outcome keeps the original decision so the change stays visible
# (CHANGELOG.md).
class RecordAppeal
  def initialize(application, user)
    @application = application
    @user = user
  end

  # A "no" answer is recorded but leaves the application as it is.
  def call(correct:)
    ActiveRecord::Base.transaction do
      @application.update!(full_remission_attributes) if correct
      @application.create_appeal!(completed_by: @user, correct: correct)
    end
    true
  end

  private

  def full_remission_attributes
    { decision: 'full', decision_cost: fee, amount_to_pay: nil, decision_date: Time.zone.now }
  end

  def fee
    @application.detail.fee
  end
end
