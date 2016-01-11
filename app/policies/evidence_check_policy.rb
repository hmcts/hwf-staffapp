class EvidenceCheckPolicy < BasePolicy
  def show?
    !admin? && same_application_office?
  end

  def update?
    !admin? && same_application_office?
  end
end
