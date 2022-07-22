module Query
  class WaitingForPartPayment
    def initialize(user)
      @user = user
    end

    def find(filter = {})
      list = @user.office.applications.waiting_for_part_payment.order(:completed_at).
             includes(:part_payment, :user, :applicant)
      list = list.joins(:detail).where(details: filter) if filter && filter[:jurisdiction_id].present?
      list
    end
  end
end
