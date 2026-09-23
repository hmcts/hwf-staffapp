module Views
  module Overview
    # Benefits rows on the online application check details page. "DWP check
    # passed" is the DWP result and "Correct evidence provided" the staff
    # answer, shown only when the DWP check did not pass. A staff answer with
    # no check counts as a failed check - see CHANGELOG.md
    module OnlineBenefitEvidence
      def dwp_check_passed
        return unless @online_application.benefits
        return if last_benefit_check.blank? && !manual_evidence_decision?

        last_benefit_check&.passed? ? 'Yes' : 'No'
      end

      def evidence_provided
        return unless @online_application.benefits && manual_evidence_decision? && !dwp_check_passed?

        @online_application.benefits_override ? 'Yes' : 'No'
      end

      def manual_evidence_decision?
        !@online_application.dwp_manual_decision.nil?
      end

      private

      def dwp_check_passed?
        last_benefit_check.present? && last_benefit_check.passed?
      end

      def last_benefit_check
        @online_application.last_benefit_check
      end
    end
  end
end
