module Evidence
  module Views
    class Overview

      APPLICATION_ATTRS = %i[date_of_birth reference full_name ni_number]
      APPLICATION_ATTRS.each do |attr|
        define_method(attr) do
          @evidence.application.send(attr)
        end
      end

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

      def processed_by
        @evidence.application.user.name
      end

      def status
        @evidence.application.married? ? 'Married' : 'Single'
      end
    end
  end
end
