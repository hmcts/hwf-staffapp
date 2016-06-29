module Views
  module Confirmation
    class Result < Views::Overview::Base

      def all_fields
        %w[savings_passed? benefits_passed? income_passed?]
      end

      def initialize(application)
        @application = application
      end

      def savings_passed?
        convert_to_pass_fail(@application.saving.passed?) if @application.saving
      end

      def benefits_passed?
        if @application.decision_override.present?
          I18n.t('activemodel.attributes.forms/application/summary.passed_by_override')
        elsif benefits_have_been_overridden?
          convert_to_pass_fail(applicant_is_on_benefits)
        elsif !benefit_overridden?
          paper_or_standard?
        end
      end

      def income_passed?
        return unless application_type_is?('income')
        path = 'activemodel.attributes.views/confirmation/result'

        income_evidence = I18n.t('income_evidence', scope: path)
        return income_evidence if @application.waiting_for_evidence?

        part_payment = I18n.t('income_part', scope: path)
        return part_payment if @application.waiting_for_part_payment?

        convert_to_pass_fail(%w[full part].include?(@application.outcome).to_s)
      end

      def result
        return 'granted' if @application.decision_override.present?
        return 'callout' if @application.evidence_check.present?
        return 'full' if return_full?
        return 'none' if @application.outcome.nil?
        %w[full part none].include?(@application.outcome) ? @application.outcome : 'error'
      end

      private

      def convert_to_pass_fail(input)
        I18n.t(input.to_s, scope: 'convert_pass_fail')
      end

      def return_full?
        !benefit_overridden? && benefit_overide_correct?
      end

      def applicant_is_on_benefits
        result = false
        if @application.benefits? && @application.last_benefit_check.present?
          result = @application.last_benefit_check.dwp_result.eql?('Yes')
        end
        result.to_s
      end

      def benefit_overide_correct?
        @application.benefit_override.correct.eql?(true)
      end

      def benefit_overridden?
        @application.benefit_override.nil?
      end

      def application_type_is?(input)
        @application.application_type.eql?(input)
      end

      def paper_or_standard?
        if benefit_overide_correct?
          I18n.t('activemodel.attributes.forms/application/summary.passed_with_evidence')
        else
          convert_to_pass_fail('false')
        end
      end

      def benefits_have_been_overridden?
        application_type_is?('benefit') && benefit_overridden?
      end
    end
  end
end
