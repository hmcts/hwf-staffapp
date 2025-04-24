module Forms
  module Evidence
    module AdditionalIncome
      def from_range
        @object.request_params[:date_range][:from].to_date
      end

      def to_range
        @object.request_params[:date_range][:to].to_date
      end

      def additional_income_value
        return additional_income_amount if additional_income_amount.to_i.positive?
        child_benefits_per_month
      end

      def child_benefits_per_month
        children = @object.evidence_check.application.children

        return 0 if children.blank? || children.zero?

        if three_months_range
          three_months_sum(children) / 3
        else
          @additional_income_from_date_range = @object.request_params[:date_range][:from].to_date
          child_benefits_per_week(children) * 4
        end
      end

      def three_months_sum(children)
        (0..2).sum do |i|
          @additional_income_from_date_range = from_range_month[i]
          child_benefits_per_week(children) * 4
        end
      end

      def child_benefits_per_week(children)
        load_benefit_rates
        return @basic_rate if children == 1

        @basic_rate + (children_multiplier(children) * @additional_rate)
      end

      def three_months_range
        (from_range..to_range).count > 31
      end

      def from_range_month
        (from_range..to_range).map(&:beginning_of_month).uniq
      end

      def children_multiplier(children)
        children - 1
      end

      def load_benefit_rates
        child_benefits_values = benefit_rates_per_year
        @basic_rate = child_benefits_values.per_week
        @additional_rate = child_benefits_values.additional_child
      end

      def benefit_rates_per_year
        Settings.child_benefits.each do |benefit_rates|
          from = benefit_rates['date_from']
          to = benefit_rates['date_to']
          return benefit_rates if @additional_income_from_date_range.between?(from.to_date, to.to_date)
        end
      end
    end
  end
end
