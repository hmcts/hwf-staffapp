module Query
  class DeletedApplications
    def initialize(user)
      @user = user
    end

    def find
      @user.office.applications.deleted.order(deleted_at: :desc)
    end
  end
end
