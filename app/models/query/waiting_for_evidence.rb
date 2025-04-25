module Query
  class WaitingForEvidence
    include FilterOrder
    def initialize(user)
      @user = user
    end

    def find(show_form_name, show_court_fee, filter = {}, order = {})
      list = @user.office.applications.
             waiting_for_evidence.
             includes(:evidence_check, :completed_by, :applicant).
             joins(:detail)

      list = list.where(detail: filter) if filter && filter[:jurisdiction_id].present?

      select_order(list, show_form_name, show_court_fee, order)
    end
  end
end
