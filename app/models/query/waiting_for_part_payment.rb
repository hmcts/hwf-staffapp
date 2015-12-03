module Query
  class WaitingForPartPayment
    def initialize(user)
      @user = user
    end

    def find
      @user.office.applications.waiting_for_part_payment.order(:completed_at)
    end
  end
end
