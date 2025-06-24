module Views
  module Overview
    module BenefitHelper

      def benefits_result
        if type.eql?('benefit')
          return format_locale('passed_by_override') if @application.decision_override.present?
          return format_locale('passed_with_evidence') if benefit_override?
          return format_locale('false') if benefit_override_failed?
          format_locale(benefit_result) if @application.last_benefit_check
        end
      end

      def benefits
        convert_to_boolean(@application.benefits?)
      end

      def benefit_result
        @application.last_benefit_check.dwp_result.eql?('Yes').to_s
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
