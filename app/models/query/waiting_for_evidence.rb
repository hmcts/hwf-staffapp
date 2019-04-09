module Query
  class WaitingForEvidence
    def initialize(user)
      @user = user
    end

    def find
      @user.office.applications.waiting_for_evidence.order(:completed_at)
        .includes(:evidence_check, :user, :applicant)
    end
  end
end
