module Views
  module Overview
    module BenefitHelper

      # Same precedence as Views::Confirmation::Result#benefits_passed? - a DWP
      # "Yes" wins over an earlier paper evidence answer - see CHANGELOG.md
      def benefits_result
        return unless type.eql?('benefit')

        if @application.decision_override.present?
          format_locale('passed_by_override')
        elsif benefit_check_passed?
          format_locale('true')
        elsif benefit_override?
          format_locale('passed_with_evidence')
        elsif benefit_override_failed? || @application.last_benefit_check.present?
          format_locale('false')
        end
      end

      def benefits
        convert_to_boolean(@application.benefits?)
      end

      def benefit_check_passed?
        @application.last_benefit_check.present? && @application.last_benefit_check.passed?
      end

      def benefit_override?
        BenefitOverride.exists?(application_id: @application.id, correct: true)
      end

      def benefit_override_failed?
        BenefitOverride.exists?(application_id: @application.id, correct: false)
      end

    end
  end
end
