module Views
  module Payment
    class Result < Views::ApplicationResult

      def initialize(payment)
        @payment = payment
        super(payment.application)
      end

      def part_payment
        format_locale(@payment.correct?.to_s)
      end

      def reason
        @payment.incorrect_reason
      end
    end
  end
end
