module Query
  class WaitingForPartPayment
    def initialize(user)
      @user = user
    end

    def find(filter = {}, order = {})
      list = @user.office.applications.
             waiting_for_part_payment.
             includes(:part_payment, :completed_by, :applicant).
             joins(:detail)

      list = list.where(details: filter) if filter && filter[:jurisdiction_id].present?
      list.order(
        "applications.completed_at #{order == 'Ascending' ? 'ASC' : 'DESC'}",
        "details.form_name DESC",
        "details.fee DESC"
      )
    end
  end
end
