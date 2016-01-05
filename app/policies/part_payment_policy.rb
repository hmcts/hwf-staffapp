class PartPaymentPolicy < BasePolicy
  def show?
    !admin? && same_office?
  end

  def update?
    !admin? && same_office?
  end

  private

  def same_office?
    @record.application.office == @user.office
  end
end
