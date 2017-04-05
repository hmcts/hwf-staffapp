module Query
  class ProcessedApplications
    def initialize(user, sort = nil)
      @user = user
      @sort = sort || { decision_date: :desc }
    end

    def find
      @user.office.applications.processed.joins(:detail).order(@sort)
    end
  end
end
