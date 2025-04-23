module Query
  class WaitingForPartPayment
    def initialize(user)
      @user = user
    end

    # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/MethodLength
    def find(show_form_name, show_court_fee, filter = {}, order = {})
      list = @user.office.applications.
             waiting_for_part_payment.
             includes(:part_payment, :completed_by, :applicant).
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
    # rubocop:enable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/MethodLength
  end
end
