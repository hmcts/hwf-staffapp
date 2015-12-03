module Query
  class RemovedApplications
    def initialize(user)
      @user = user
    end

    def find
      @user.office.applications.removed.order(:id)
    end
  end
end
