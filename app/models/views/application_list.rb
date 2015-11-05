module Views
  class ApplicationList
    attr_reader :application

    def initialize(application)
      @application = application
    end

    def applicant
      @application.applicant.full_name
    end

    def date_received
      @application.detail.date_received.to_s(:gov_uk_long)
    end

    def processed_by
      @application.user.name
    end

    def emergency
      scope = 'emergency.status'
      status = @application.detail.emergency_reason.present?.to_s

      I18n.t(status, scope: scope)
    end
  end
end
