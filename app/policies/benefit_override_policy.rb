class BenefitOverridePolicy < BasePolicy
  def create?
    staff_or_manager? && same_application_office?
  end
end
