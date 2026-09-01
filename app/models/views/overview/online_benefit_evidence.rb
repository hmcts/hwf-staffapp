module Views
  module Overview
    # "Correct evidence provided" on the online application check details page:
    # the staff member's manual answer when the DWP check was skipped or
    # errored, otherwise the DWP result (CHANGELOG.md)
    module OnlineBenefitEvidence
      def evidence_provided
        return nil unless @online_application.benefits
        decision = evidence_decision
        return nil if decision.nil?
        decision ? 'Yes' : 'No'
      end

      def manual_evidence_decision?
        !@online_application.dwp_manual_decision.nil?
      end

      private

      def evidence_decision
        return @online_application.benefits_override if manual_evidence_decision?
        @online_application.last_benefit_check&.passed?
      end
    end
  end
end
