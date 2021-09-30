module Forms
  module Evidence
    class HmrcCheck < ::FormObject
      include ActiveModel::Validations::Callbacks

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
          additional_income: Boolean
        }
      end

      define_attributes

      before_validation :format_dates
      # , :validate_range, :validate_range_against_submission

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

      def validate_range_against_submission
        return if errors.any?
        created = @object.evidence_check.application.created_at.to_date
        last_month = created - 1.month
        return if @from_date == last_month.beginning_of_month
        message = range_message(last_month)
        errors.add(:date_range, message)
      end

      def range_message(month)
        start_month = month.beginning_of_month.strftime('%d/%m/%Y')
        end_month = month.end_of_month.strftime('%d/%m/%Y')
        range = "#{start_month} - #{end_month}"
        "Enter a calendar month date range prior to the application submission date: #{range}"
      end

    end
  end
end
