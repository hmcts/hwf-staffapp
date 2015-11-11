module Query
  class WaitingForPartPayment < Query::WaitingForBase
    def find
      super(:part_payment)
    end
  end
end
