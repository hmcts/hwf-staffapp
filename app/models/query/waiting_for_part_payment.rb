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
        Arel.sql("applications.completed_at #{order == 'Ascending' ? 'ASC' : 'DESC'}"),
        Arel.sql('details.form_name DESC'),
        Arel.sql('details.fee DESC')
      )
    end
  end
end
