module Query
  class WaitingForEvidence
    def initialize(user)
      @user = user
    end

    def find
      @user.office.applications.waiting_for_evidence.order(:completed_at)
    end
  end
end
