module Views
  module Overview
    class Application
      include OverviewHelper
      include HmrcHelper
      include IncomeHelper
      include BenefitHelper

      include ActionView::Helpers::NumberHelper

      delegate(:reference, to: :@application)

      def initialize(application)
        @application = application
      end

      def all_fields
        ['benefits', 'dependants', 'number_of_children', 'total_monthly_income', 'savings']
      end

      delegate :state, to: :@application

      def evidence_check_outcome
        @application.evidence_check.outcome
      end

      def part_payment_outcome
        @application.part_payment&.outcome
      end

      def savings_result
        format_locale(@application.saving.passed?.to_s)
      end

      def calculation_scheme
        if @application.detail.calculation_scheme.blank?
          return format_locale(FeatureSwitching::CALCULATION_SCHEMAS[0].to_s)
        end
        format_locale(@application.detail.calculation_scheme.to_s)
      end

      def paper_evidence
        return if @application.benefit_override.blank?
        format_locale(@application.benefit_override.correct)
      end

      def type
        @application.application_type
      end

      def refund
        @application.detail.refund
      end

      def amount_to_refund
        @application.detail.fee - (@application.amount_to_pay || 0)
      end

      def result
        return @application.evidence_check.outcome if evidence_completed?
        @application.outcome
      end

      def total_monthly_income
        @application.income ? format_currency(@application.income.round) : format_threshold_income
      end

      def total_monthly_income_from_evidence
        return nil if @application.evidence_check.blank?
        format_currency(@application.evidence_check.income.try(:round))
      end

      def number_of_children
        if @application.children_age_band.blank?
          @application.children
        else
          children_age_band
        end
      end

      def return_type
        {
          'evidence_check' => 'evidence',
          'part_payment' => 'payment'
        }[@application.decision_type] || nil
      end

      def amount_to_pay
        if evidence_or_application.amount_to_pay.present?
          "£#{parse_amount_to_pay(evidence_or_application.amount_to_pay)}"
        elsif @application.amount_to_pay
          "£#{parse_amount_to_pay(@application.amount_to_pay)}"
        end
      end

      def hmrc_checked?
        return 'No' if @application.evidence_check.blank?
        @application.evidence_check.income_check_type == 'hmrc' ? 'Yes' : 'No'
      end

      def display_benefits?
        @application.benefits == true
      end

      def display_income?
        !@application.benefits && @application.saving.passed
      end

      def display_savings?
        !@application.benefits
      end

      private

      def evidence_completed?
        @application.evidence_check&.completed_at && @application.evidence_check.outcome
      end

      def parse_amount_to_pay(amount_to_pay)
        (amount_to_pay % 1).zero? ? amount_to_pay.to_i : amount_to_pay
      end

      def evidence_or_application
        @application.evidence_check || @application
      end

      def format_locale(suffix)
        I18n.t(suffix, scope: 'activemodel.attributes.forms/application/summary')
      end

      def format_currency(amount)
        number_to_currency(amount, precision: 0, unit: '£')
      end

      def convert_to_boolean(input)
        I18n.t("convert_boolean.#{input.presence || 'false'}")
      end
    end
  end
end
