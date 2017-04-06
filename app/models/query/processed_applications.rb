module Query
  class ProcessedApplications
    def initialize(user, sort = nil)
      @user = user
      @sort = sort || { decision_date: :desc }
    end

    def find
      @user.office.applications.processed.joins(:detail).order(@sort)
    end

    def search(reference)
      @user.office.applications.processed.
        joins(:detail).where(reference: reference)
    end
  end
end
