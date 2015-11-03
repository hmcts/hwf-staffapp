module Query
  class WaitingForPayment < Query::WaitingForBase
    def find
      super(:payment)
    end
  end
end
