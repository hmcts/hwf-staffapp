module Query
  class EvidenceCheckable
    def initialize(relation = Application)
      @relation = relation
    end

    def find_all
      @relation.
        includes(:detail).
        references(:detail).
        where(where_condition)
    end

    private

    def where_condition
      {
        applications: {
          benefits: false,
          application_type: 'income',
          outcome: %w[part full]
        },
        details: {
          emergency_reason: nil
        }
      }
    end
  end
end
