module Query
  class LastUpdatedApplications
    def initialize(user)
      @user = user
    end

    def find
      @user.applications.order(updated_at: :desc).limit(5)
    end
  end
end
