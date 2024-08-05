module Views
  module Overview

    module OverviewHelper
      def children_age_band
        return nil if @application.children_age_band.blank?
        one = age_band_value(1)
        two = age_band_value(2)
        return nil if one.zero? && two.zero?
        # rubocop:disable Rails/OutputSafety
        "#{one} (aged 0-13) <br />
         #{two} (aged 14+)".html_safe
        # rubocop:enable Rails/OutputSafety
      end

      def age_band_value(band_name)
        band = @application.children_age_band

        case band_name
        when 1
          (band[:one] || band['one'] || 0).to_i
        when 2
          (band[:two] || band['two'] || 0).to_i
        end
      end

      def calculation_scheme_value
        @application.detail.calculation_scheme
      end

      def format_threshold_income
        if @application.income_min_threshold_exceeded == false
          I18n.t('income.below_threshold', threshold: format_currency(thresholds.min_threshold))
        elsif @application.income_max_threshold_exceeded
          I18n.t('income.above_threshold', threshold: format_currency(thresholds.max_threshold))
        end
      end

      def thresholds
        IncomeThresholds.new(@application.applicant.married, @application.children)
      end

      def married?
        @application.applicant.married
      end

    end
  end
end
