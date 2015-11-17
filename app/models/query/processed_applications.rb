module Query
  class ProcessedApplications
    def initialize(user)
      @user = user
    end

    def find
      @user.office.applications.
        includes(:evidence_check, :part_payment).
        references(:evidence_check, :part_payment).
        where(where_condition).
        order(id: :asc)
    end

    def where_condition
      <<-WHERE.gsub(/^\s+\|/, '')
        |(applications.outcome IS NOT NULL)
        |AND
        |(applications.completed_at IS NOT NULL)
        |AND
        |(evidence_checks.id IS NULL OR evidence_checks.completed_at IS NOT NULL)
        |AND
        |(part_payments.id IS NULL OR part_payments.completed_at IS NOT NULL)
      WHERE
    end
  end
end
