module Query
  class WaitingForEvidence
    def initialize(user)
      @user = user
    end

    def find(filter = {}, order = {})
      list = @user.office.applications.waiting_for_evidence.
             order(completed_at: order == "Ascending" ? :asc : :desc).
             includes(:evidence_check, :completed_by, :applicant)
      list = list.joins(:detail).where(details: filter) if filter && filter[:jurisdiction_id].present?
      list
    end
  end
end
