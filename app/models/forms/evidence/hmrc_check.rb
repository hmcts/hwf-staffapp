module Forms
  module Evidence
    class HmrcCheck < ::FormObject
      include ActiveModel::Validations::Callbacks

      # rubocop:disable Metrics/MethodLength
      def self.permitted_attributes
        {
          from_date: Date,
          from_date_day: Integer,
          from_date_month: Integer,
          from_date_year: Integer,
          to_date: Date,
          to_date_day: Integer,
          to_date_month: Integer,
          to_date_year: Integer,
          additional_income: Boolean,
          additional_income_amount: Integer,
          user_id: Integer
        }
      end
      # rubocop:enable Metrics/MethodLength

      define_attributes

      before_validation :format_dates, unless: :income_step?
      validate :validate_range, unless: :income_step?
      validate :additional_income_check
      validates :additional_income_amount, numericality: { greater_than_or_equal_to: 0 }, if: :income_step?

      def from_date
        @from_date.strftime("%Y-%m-%d")
      end

      def to_date
        @to_date.strftime("%Y-%m-%d")
      end

      def load_additional_income_from_benefits
        if child_benefits_per_month.positive?
          self.additional_income = true
          self.additional_income_amount = additional_income_value
        end
      end

      def additional_income_value
        return additional_income_amount if additional_income_amount.to_i.positive?
        child_benefits_per_month
      end

      def child_benefits_per_month
        children = @object.evidence_check.application.children

        return 0 if children.blank? || children.zero?
        child_benefits_per_week(children) * 4
      end

      def child_benefits_per_week(children)
        basic_rate = Settings.child_benefits.per_week
        additional_rate = Settings.child_benefits.additional_child
        return basic_rate if children == 1
        children_multiplier = children - 1

        basic_rate + (children_multiplier * additional_rate)
      end

      private

      def persist!
        @object.update(fields_to_update)
      end

      def fields_to_update
        { additional_income: additional_income_amount }
      end

      def format_dates
        begin
          @from_date = concat_from_date.to_date
        rescue NoMethodError, Date::Error
          errors.add(:from_date, "Format of From date is not valid")
        end
        begin
          @to_date = concat_to_date.to_date
        rescue NoMethodError, Date::Error
          errors.add(:to_date, "Format of To date is not valid")
        end
      end

      # YYYY-MM-DD
      def concat_from_date
        return nil if from_date_day.blank? || from_date_month.blank? ||
                      from_date_year.blank?
        "#{from_date_year}-#{from_date_month}-#{from_date_day}"
      end

      # YYYY-MM-DD
      def concat_to_date
        return nil if to_date_day.blank? || to_date_month.blank? ||
                      to_date_year.blank?
        "#{to_date_year}-#{to_date_month}-#{to_date_day}"
      end

      def validate_range
        return if errors.any?
        return if (@from_date + 1.month) - 1.day == @to_date
        errors.add(:date_range, "Enter a calendar month date range")
      end

      def additional_income_check
        return unless income_step?
        return unless additional_income_amount.nil?
        errors.add(:additional_income_amount, "Can't be empty")
      end

      def income_step?
        return false if additional_income.nil?
        true
      end
    end
  end
end
