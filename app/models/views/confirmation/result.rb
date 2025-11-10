# rubocop:disable Metrics/ClassLength
module Views
  module Confirmation
    class Result < Views::Overview::Base

      def all_fields
        list = ['discretion_applied?', 'savings_passed?', 'benefits_passed?', 'income_passed?']
        list << 'calculation_scheme' if FeatureSwitching.active?(:band_calculation)
        list
      end

      def initialize(application)
        @application = application
      end

      delegate :representative, to: :@application

      def representative_full_name
        return if representative.blank?

        "#{representative.first_name} #{representative.last_name}".strip
      end

      def savings_passed?
        passed = @application.saving.passed
        return false if passed.nil?
        if decision_overridden? && passed == false
          return I18n.t('activemodel.attributes.forms/application/summary.passed_by_override')
        end
        return false if @application.detail.discretion_applied == false
        convert_to_pass_fail(@application.saving.passed?) if @application.saving
      end

      def allow_override?
        return false if @application.benefits
        return false if @application.saving.passed == false && @application.online_application_id.blank?
        true
      end

      # rubocop:disable Style/ReturnNilInPredicateMethodDefinition
      def benefits_passed?
        return nil if @application.benefits.blank?

        if decision_overridden?
          I18n.t('activemodel.attributes.forms/application/summary.passed_by_override')
        elsif benefits_have_been_overridden?
          benefit_override_result
        elsif @application.last_benefit_check.present?
          convert_to_pass_fail(@application.last_benefit_check.passed?)
        end
      end
      # rubocop:enable Style/ReturnNilInPredicateMethodDefinition

      def income_passed?
        return false unless application_type_is?('income')
        path = 'activemodel.attributes.views/confirmation/result'

        return I18n.t('income_evidence', scope: path) if @application.waiting_for_evidence?

        return I18n.t('income_part', scope: path) if @application.waiting_for_part_payment?

        if decision_overridden? && income_over_limit?
          I18n.t('activemodel.attributes.forms/application/summary.passed_by_override')
        else
          convert_to_pass_fail(['full', 'part'].include?(outcome).to_s)
        end
      end

      def discretion_applied?
        discretion_value = @application.detail.discretion_applied
        return false if discretion_value.nil?

        if decision_overridden?
          I18n.t('activemodel.attributes.forms/application/summary.passed_by_override')
        else
          convert_to_pass_fail(@application.detail.discretion_applied)
        end
      end

      def decision_overridden?
        @application.decision_override.present? && @application.decision_override.id
      end

      def amount_to_pay
        if @application.evidence_check && !@application.waiting_for_evidence?
          @application.evidence_check.amount_to_pay
        else
          @application.amount_to_pay
        end
      end

      def result
        return 'granted' if decision_overridden?
        return 'callout' if @application.waiting_for_evidence?
        return 'full' if return_full?
        return 'none' if @application.outcome.nil?
        ['full', 'part', 'none'].include?(outcome) ? outcome : 'error'
      end

      def outcome
        if @application.evidence_check && !@application.waiting_for_evidence?
          @application.evidence_check.outcome
        else
          @application.outcome
        end
      end

      def expires_at
        if @application.waiting_for_part_payment?
          @application.part_payment.expires_at.try(:strftime, Date::DATE_FORMATS[:gov_uk_long])
        elsif @application.evidence_check
          @application.evidence_check.expires_at.try(:strftime, Date::DATE_FORMATS[:gov_uk_long])
        else
          @application.payment_expires_at.try(:strftime, Date::DATE_FORMATS[:gov_uk_long])
        end
      end

      def income
        return @application.evidence_check.income if @application.evidence_check.try(:income).try(:positive?)
        @application.income
      end

      def calculation_scheme
        if @application.detail.calculation_scheme.blank?
          I18n.t('activemodel.attributes.forms/application/summary.prior_q4_23')
        else
          scheme_value = @application.detail.calculation_scheme
          I18n.t("activemodel.attributes.forms/application/summary.#{scheme_value}")
        end
      end

      private

      def convert_to_pass_fail(input)
        I18n.t(input.to_s, scope: 'convert_pass_fail')
      end

      def return_full?
        !benefit_overridden? && benefit_overide_correct?
      end

      def applicant_is_on_benefits
        if @application.benefits? && @application.last_benefit_check.present?
          result = @application.last_benefit_check.dwp_result.eql?('Yes')
        end
        result.to_s
      end

      def benefit_overide_correct?
        @application.benefit_override&.correct.eql?(true)
      end

      def benefit_overridden?
        @application.benefit_override.present?
      end

      def application_type_is?(input)
        @application.application_type.eql?(input)
      end

      def benefit_override_result
        if benefit_overide_correct?
          I18n.t('activemodel.attributes.forms/application/summary.passed_with_evidence')
        else
          I18n.t('activemodel.attributes.forms/application/summary.failed')
        end
      end

      def benefits_have_been_overridden?
        application_type_is?('benefit') && benefit_overridden?
      end

      def income_over_limit?
        @application.income_max_threshold_exceeded == true
      end

      def online_and_failed_on_benefits?
        @application.online_application_id.present? && benefit_check_failed?
      end

      def benefit_check_failed?
        bc = @application.benefit_checks.last
        return false unless bc.nil?
        !bc.passed?
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
