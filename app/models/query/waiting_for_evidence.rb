module Query
  class WaitingForEvidence
    def initialize(user)
      @user = user
    end

    def find
      @user.office.applications.includes(:evidence_check).
        references(:evidence_check).
        where('evidence_checks.completed_at IS NULL').
        where.not(evidence_checks: { id: nil }).
        order('evidence_checks.expires_at ASC')
    end
  end
end
