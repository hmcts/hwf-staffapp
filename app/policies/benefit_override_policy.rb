class BenefitOverridePolicy < BasePolicy
  def create?
    !admin? && same_application_office?
  end
end
