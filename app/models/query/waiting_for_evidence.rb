module Query
  class WaitingForEvidence
    def initialize(user)
      @user = user
    end

    def find(filter = {}, order = {}, show_form_name = false, show_court_fee = false)
      list = @user.office.applications.
             waiting_for_evidence.
             includes(:evidence_check, :completed_by, :applicant).
             joins(:detail)

      list = list.where(details: filter) if filter && filter[:jurisdiction_id].present?
      if show_form_name
        list.order(
          "detail.form_name DESC",
          "applications.completed_at #{order == 'Ascending' ? 'ASC' : 'DESC'}"
        )
      elsif show_court_fee
        list.order(
          "detail.fee DESC",
          "applications.completed_at #{order == 'Ascending' ? 'ASC' : 'DESC'}"
        )
      else
        list.order("applications.completed_at #{order == 'Ascending' ? 'ASC' : 'DESC'}")
      end
    end
  end
end
