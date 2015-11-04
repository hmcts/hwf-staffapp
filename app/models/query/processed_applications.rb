module Query
  class ProcessedApplications
    def initialize(user)
      @user = user
    end

    def find
      @user.office.applications.
        includes(:evidence_check, :payment).
        references(:evidence_check, :payment).
        where(where_condition).
        order(id: :asc)
    end

    def where_condition
      <<WHERE
(evidence_checks.id IS NULL OR evidence_checks.completed_at IS NOT NULL)
AND
(payments.id IS NULL OR payments.completed_at IS NOT NULL)
WHERE
    end
  end
end
