module Views
  module Evidence
    class ProcessingDetails
      attr_reader :application, :evidence

      delegate :reference, to: :application

      def initialize(evidence)
        @evidence = evidence
        @application = evidence.application
      end

      def expires
        return 'expired' if @evidence.expires_at < Time.zone.now
        days = (((@evidence.expires_at - Time.zone.now) / 86400).round)
        if days > 1
          "#{days} days"
        elsif days == 1
          "1 day"
        end
      end

      def processed_by
        @application.user.name
      end

      def applicant
        @application.full_name
      end
    end
  end
end
