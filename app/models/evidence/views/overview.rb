module Evidence
  module Views
    class Overview
      EVIDENCE = %i[expires_at]
      def initialize(evidence)
        @evidence = evidence
      end

      def expires
        days = (((@evidence.expires_at - Time.zone.now) / 86400).round)
        if days > 1
          "#{days} days"
        elsif days == 1
          "1 day"
        else
          "expired"
        end
      end

      def reference
        @evidence.application.reference
      end

      def processed_by
        @evidence.application.user.name
      end
    end
  end
end
