module Query
  class WaitingForEvidence
    def initialize(user)
      @user = user
    end

    def find(filter = {}, order = {})
      list = @user.office.applications.
             waiting_for_evidence.
             includes(:evidence_check, :completed_by, :applicant).
             joins(:detail)

      list = list.where(details: filter) if filter && filter[:jurisdiction_id].present?
      list.order(
        "applications.completed_at #{order == 'Ascending' ? 'ASC' : 'DESC'}",
        "detail.form_name DESC",
        "detail.fee DESC"
      )
    end
  end
end
