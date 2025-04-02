module Query
  class WaitingForPartPayment
    def initialize(user)
      @user = user
    end

    def find(filter = {}, order = {})
      list = @user.office.applications.waiting_for_part_payment.
             order(completed_at: order == "Ascending" ? :asc : :desc).
             includes(:part_payment, :applicant, :completed_by)
      list = list.joins(:detail).where(details: filter) if filter && filter[:jurisdiction_id].present?
      list
    end
  end
end
