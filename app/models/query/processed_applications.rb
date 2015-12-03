module Query
  class ProcessedApplications
    def initialize(user)
      @user = user
    end

    def find
      @user.office.applications.processed.order(:id)
    end
  end
end
