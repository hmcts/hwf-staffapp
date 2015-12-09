module Views
  class ApplicationList
    attr_reader :application

    def initialize(application)
      @application = application
    end

    def id
      @application.id
    end

    def reference
      @application.reference
    end

    def applicant
      @application.applicant.full_name
    end

    def date_received
      @application.detail.date_received.to_s(:gov_uk_long)
    end

    def processed_by
      @application.completed_by.try(:name)
    end

    def processed_on
      @application.completed_at.try(:strftime, Date::DATE_FORMATS[:gov_uk_long])
    end

    def emergency
      scope = 'emergency.status'
      status = @application.detail.emergency_reason.present?.to_s

      I18n.t(status, scope: scope)
    end
  end
end
