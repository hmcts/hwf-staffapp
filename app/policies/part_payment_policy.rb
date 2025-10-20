class PartPaymentPolicy < BasePolicy
  def show?
    ((staff_or_manager? || reader?) && same_application_office?) || admin?
  end

  def update?
    staff_or_manager? && same_application_office?
  end
end
