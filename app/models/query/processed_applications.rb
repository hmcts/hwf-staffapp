module Query
  class ProcessedApplications
    def initialize(user, sort = nil)
      @user = user
      @sort = sort || { decision_date: :desc }
    end

    def find(filter = {})
      list = @user.office.applications.processed.
             includes(:benefit_checks, :evidence_check, :applicant, :part_payment, :detail, :online_application, :decision_override).
             joins(:detail).order(@sort)
      list = list.where(details: filter) if filter && filter[:jurisdiction_id].present?
      list
    end

    def search(reference)
      @user.office.applications.processed.
        joins(:detail).where(reference: reference)
    end
  end
end
