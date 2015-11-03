module Query
  class WaitingForEvidence < Query::WaitingForBase
    def find
      super(:evidence_check)
    end
  end
end
