module Query
  class ProcessedApplications
    def find
      Application.
        includes(:evidence_check, :payment).
        references(:evidence_check, :payment).
        where(where_condition)
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
