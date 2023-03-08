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

    def position(id, refund, frequency)
      Application.joins(:detail).where(
        {applications:{benefits: false, purged: false,
                       application_type: 'income', outcome: ['part', 'full']},
         details: {emergency_reason: nil, refund: refund}}).where('applications.id < ?', id).last(frequency)
    end

    private

    def where_condition
      {
        applications: {
          benefits: false,
          application_type: 'income',
          outcome: ['part', 'full']
        },
        details: {
          emergency_reason: nil
        }
      }
    end
  end
end
