module Query
  class EvidenceCheckable
    def initialize(relation = Application)
      @relation = relation
    end

    def find_all
      @relation.where(
        benefits: false,
        application_type: 'income',
        emergency_reason: nil,
        application_outcome: %w[part full]
      )
    end
  end
end
