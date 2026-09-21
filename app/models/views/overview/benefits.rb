module Views
  module Overview
    class Benefits < Base

      def all_fields
        ['on_benefits?', 'dwp_check_passed?', 'override?']
      end

      def initialize(application)
        @application = application
      end

      def on_benefits?
        convert_to_boolean(@application.benefits?)
      end

      # The DWP result cannot be changed by staff, only the paper evidence answer.
      def skip_change_link
        ['dwp_check_passed?']
      end

      # "DWP check passed" is the DWP result and "Correct evidence provided"
      # the staff paper evidence answer, shown only when the DWP check did not
      # pass. An override with no check counts as a failed check - see CHANGELOG.md
      # rubocop:disable Style/ReturnNilInPredicateMethodDefinition
      def dwp_check_passed?
        return unless @application.benefits?
        return if last_benefit_check.blank? && !benefit_overridden?

        convert_to_boolean(last_benefit_check&.passed?)
      end

      def override?
        return unless @application.benefits? && benefit_overridden? && !dwp_check_passed

        convert_to_boolean(@application.benefit_override.correct)
      end
      # rubocop:enable Style/ReturnNilInPredicateMethodDefinition

      private

      def dwp_check_passed
        last_benefit_check.present? && last_benefit_check.passed?
      end

      def last_benefit_check
        @application.last_benefit_check
      end

      def benefit_overridden?
        !@application.benefit_override.nil?
      end
    end
  end
end
