module Query
  class WaitingForPartPayment
    include FilterOrder

    def initialize(user)
      @user = user
    end

    def find(filter: {}, sort: {})
      list = @user.office.applications.
             waiting_for_part_payment.
             includes(:part_payment, :completed_by, :applicant, detail: :jurisdiction).
             references(:detail)

      if filter && filter[:jurisdiction_id].present?
        list = list.where(details: { jurisdiction_id: filter[:jurisdiction_id] })
      end

      select_order(list, sort)
    end
  end
end
