module Views
  module Overview
    module HmrcHelper

      def hmrc_view_total_monthly_income
        return total_monthly_income if @application.income_period_last_month?
        'N/A'
      end

      def average_monthly_income
        return total_monthly_income if @application.income_period_three_months_average?
        'N/A'
      end
      
    end
  end
end
