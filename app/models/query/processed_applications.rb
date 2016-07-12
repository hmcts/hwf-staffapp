module Query
  class ProcessedApplications
    def initialize(user)
      @user = user
    end

    def find
      @user.office.applications.processed.order(decision_date: :desc)
    end
  end
end
