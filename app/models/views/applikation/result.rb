module Views
  module Applikation
    class Result < Views::ApplicationResult

      def result
        if @application.evidence_check?
          'callout'
        elsif !benefit_overridden? && benefit_ovveride_correct?
          'full'
        elsif @application.application_outcome.nil?
          'none'
        else
          super
        end
      end

      private

      def benefit_ovveride_correct?
        @application.benefit_override.correct.equal?(true)
      end

      def benefit_overridden?
        @application.benefit_override.nil?
      end
    end
  end
end
