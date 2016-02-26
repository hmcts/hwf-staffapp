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
        convert_to_pass_fail(@application.savings_investment_valid?)
      end

      def benefits_passed?
        if application_type_is?('benefit') && benefit_overridden?
          convert_to_pass_fail(applicant_is_on_benefits)
        elsif !benefit_overridden?
          if benefit_overide_correct?
            I18n.t('activemodel.attributes.forms/application/summary.passed_with_evidence')
          else
            convert_to_pass_fail('false')
          end
        end
      end

      def income_passed?
        if application_type_is?('income')
          if @application.waiting_for_evidence?
            I18n.t('activemodel.attributes.views/confirmation/result.income_evidence')
          elsif @application.waiting_for_part_payment?
            I18n.t('activemodel.attributes.views/confirmation/result.income_part')
          else
            convert_to_pass_fail(%w[full part].include?(@application.outcome).to_s)
          end
        end
      end

      def result
        if @application.evidence_check.present?
          'callout'
        elsif !benefit_overridden? && benefit_overide_correct?
          'full'
        elsif @application.outcome.nil?
          'none'
        else
          %w[full part none].include?(@application.outcome) ? @application.outcome : 'error'
        end
      end

      private

      def convert_to_pass_fail(input)
        I18n.t(input, scope: 'convert_pass_fail')
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
    end
  end
end
