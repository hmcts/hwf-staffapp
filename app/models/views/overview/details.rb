module Views
  module Overview
    class Details
      include ActionView::Helpers::NumberHelper

      delegate(:form_name, :case_number, :deceased_name, :emergency_reason, to: :detail)

      def initialize(application)
        @application = application
      end

      def all_fields
        %w[fee jurisdiction date_received form_name case_number
           deceased_name date_of_death date_fee_paid emergency_reason]
      end

      def fee
        number_to_currency(detail.fee.round, precision: 0, unit: '£')
      end

      def jurisdiction
        detail.jurisdiction.name
      end

      %i[date_received date_of_death date_fee_paid].each do |method|
        define_method(method) do
          format_date(detail.public_send(method))
        end
      end

      private

      def detail
        @application.detail
      end

      def format_date(date)
        date.to_s(:gov_uk_long) if date
      end
    end
  end
end
