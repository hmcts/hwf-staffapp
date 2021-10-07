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
          additional_income_amount: Integer
        }
      end
      # rubocop:enable Metrics/MethodLength

      define_attributes

      before_validation :format_dates, :validate_range

      def from_date
        @from_date.strftime("%Y-%m-%d")
      end

      def to_date
        @to_date.strftime("%Y-%m-%d")
      end

      private

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

    end
  end
end
