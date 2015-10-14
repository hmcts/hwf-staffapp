module Evidence
  module Views
    class Overview
      attr_reader :evidence

      APPLICATION_ATTRS = %i[date_of_birth full_name ni_number
                             date_received form_name amount_to_pay]
      APPLICATION_ATTRS.each do |attr|
        define_method(attr) do
          @evidence.application.send(attr)
        end
      end

      def initialize(evidence)
        @evidence = evidence
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
          'full' => I18n.t('activerecord.attributes.application.summary.passed'),
          'part' => I18n.t('activerecord.attributes.application.summary.passed'),
          'none' => I18n.t('activerecord.attributes.application.summary.failed')
        }[@evidence.application.application_outcome]
      end

      def savings
        {
          'true' => I18n.t('activerecord.attributes.application.summary.passed'),
          'false' => I18n.t('activerecord.attributes.application.summary.failed')
        }[@evidence.application.savings_investment_valid?.to_s]
      end

      def result
        @evidence.application.application_outcome
      end
    end
  end
end
