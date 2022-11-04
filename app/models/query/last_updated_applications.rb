module Query
  class LastUpdatedApplications
    def initialize(user)
      @user = user
    end

    def find(limit: nil)
      @user.applications.includes(:benefit_checks).order(updated_at: :desc).limit(limit)
    end
  end
end
