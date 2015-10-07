module Evidence
  module Views
    class Overview

      APPLICATION_ATTRS = %i[date_of_birth reference full_name ni_number
                             date_received form_name amount_to_pay]
      APPLICATION_ATTRS.each do |attr|
        define_method(attr) do
          @evidence.application.send(attr)
        end
      end

      def initialize(evidence)
        @evidence = evidence
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
        @evidence.application.user.name
      end

      def status
        @evidence.application.married? ? 'Married' : 'Single'
      end

      def jurisdiction
        @evidence.application.jurisdiction.name
      end

      def fee
        "£#{@evidence.application.fee.round}"
      end

      def number_of_children
        @evidence.application.children
      end

      def total_monthly_income
        "£#{@evidence.application.income.round}"
      end

      def income
        {
          'full' => '&#10003; Passed',
          'part' => '&#10003; Passed',
          'none' => '&#10007; Failed'
        }[@evidence.application.application_outcome]
      end

      def savings
        {
          'true' => '&#10003; Passed',
          'false' => '&#10007; Failed'
        }[@evidence.application.savings_investment_valid?.to_s]
      end

      def result
        @evidence.application.application_outcome
      end
    end
  end
end
