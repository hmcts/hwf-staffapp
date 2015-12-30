class BenefitOverridePolicy < BasePolicy
  def create?
    !admin? && same_office?
  end

  private

  def same_office?
    @record.application.office == @user.office
  end
end
