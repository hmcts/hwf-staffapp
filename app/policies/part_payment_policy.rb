class PartPaymentPolicy < BasePolicy
  def show?
    (staff_or_manager? || reader? || admin?) && same_application_office?
  end

  def update?
    staff_or_manager? && same_application_office?
  end
end
