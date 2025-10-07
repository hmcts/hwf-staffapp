class EvidenceCheckPolicy < BasePolicy
  def new?
    (staff_or_manager? || reader?) && same_application_office?
  end

  def create?
    (staff_or_manager? || reader?) && same_application_office?
  end

  def show?
    (staff_or_manager? || reader? || admin?) && same_application_office?
  end

  def update?
    staff_or_manager? && same_application_office?
  end

  def complete?
    staff_or_manager? && same_application_office?
  end
end
