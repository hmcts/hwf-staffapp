module Query
  class EvidenceCheckable
    def initialize(relation = Application)
      @relation = relation
    end

    def find_all
      @relation.
        includes(:detail).
        references(:detail).
        where(
          applications: {
            benefits: false,
            application_type: 'income',
            application_outcome: %w[part full],
          },
          details: { emergency_reason: nil }
        )
    end
  end
end
