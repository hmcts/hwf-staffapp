module Query
  class WaitingForPayment
    def initialize(user)
      @user = user
    end

    def find
      @user.office.applications.includes(:payment).
        references(:payment).
        where('payments.completed_at IS NULL').
        where.not(payments: { id: nil }).
        order('payments.expires_at ASC')
    end
  end
end
