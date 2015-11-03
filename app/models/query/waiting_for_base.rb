module Query
  class WaitingForBase
    def initialize(user)
      @user = user
    end

    def find(attribute)
      db_field = attribute.to_s.pluralize
      @user.office.applications.includes(attribute).
        references(attribute).
        where("#{db_field}.completed_at IS NULL").
        where("#{db_field}.id IS NOT NULL").
        order("#{db_field}.expires_at ASC")
    end
  end
end
