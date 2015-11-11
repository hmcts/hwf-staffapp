module Views
  module PartPayment
    class Result < Views::ApplicationResult

      def initialize(part_payment)
        @part_payment = part_payment
        super(@part_payment.application)
      end

      def part_payment
        format_locale(@part_payment.correct?.to_s)
      end

      def reason
        @part_payment.incorrect_reason
      end

      def callout
        @part_payment.correct? ? 'yes' : 'no'
      end
    end
  end
end
