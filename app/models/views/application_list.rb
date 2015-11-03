module Views
  class ApplicationList
    attr_reader :application

    delegate :reference, to: :application

    def initialize(application)
      @application = application
    end

    def applicant
      @application.applicant.full_name
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
