module Forms
  module Application
    class FeeStatus < ::FormObject
      include ActiveModel::Validations::Callbacks
      include DataFieldFormattable
      include RefundValidatable

      # rubocop:disable Metrics/MethodLength
      def self.permitted_attributes
        {
          date_received: Date,
          day_date_received: Integer,
          month_date_received: Integer,
          year_date_received: Integer,
          refund: Boolean,
          date_fee_paid: Date,
          day_date_fee_paid: Integer,
          month_date_fee_paid: Integer,
          year_date_fee_paid: Integer,
          discretion_applied: Boolean,
          discretion_manager_name: String,
          discretion_reason: String,
          calculation_scheme: String
        }
      end
      # rubocop:enable Metrics/MethodLength

      define_attributes

      before_validation :format_date_fields
      after_validation :reset_discretion
      after_validation :check_refund_values
      after_validation :update_calculation_scheme

      validates :discretion_manager_name,
                :discretion_reason, presence: true, if: proc { |detail| detail.discretion_applied }
      validates :refund, inclusion: { in: [true, false] }

      validates :date_received, date: {
        before: :tomorrow
      }
      validate :date_received_within_limit

      validates :date_fee_paid, presence: true, if: proc { |detail| detail.refund && discretion_applied != true }
      validates :discretion_applied, presence: true, if: proc { validate_discretion? }
      validate :calculation_scheme_change

      with_options if: :validate_date_fee_paid? do
        validates :date_fee_paid, date: {
          after_or_equal_to: :max_refund_date,
          before_or_equal_to: :date_received
        }
      end

      def format_date_fields
        [:date_received, :date_fee_paid].each do |key|
          format_dates(key) if format_the_dates?(key)
        end
      end

      private

      def update_calculation_scheme
        self.calculation_scheme = FeatureSwitching.calculation_scheme(calculation_scheme_data)
      end

      def min_date
        3.months.ago.midnight
      end

      def date_received_within_limit
        if date_received.present?
          begin
            parsed_date = date_received.to_date
            if parsed_date < 2.years.ago.to_date
              errors.add(:date_received, "Please enter a valid date in the correct format DD/MM/YYYY")
            end
          rescue ArgumentError
            # If the date is invalid (like day = 32), do nothing; let other validations handle it
          end
        end
      end

      def tomorrow
        Time.zone.tomorrow
      end

      def persist!
        @object.update(fields_to_update)
      end

      def fields_to_update
        excluded_keys = [:day_date_received, :month_date_received, :year_date_received,
                         :day_date_fee_paid, :month_date_fee_paid, :year_date_fee_paid]
        {}.tap do |fields|
          (self.class.permitted_attributes.keys - excluded_keys).each do |name|
            fields[name] = send(name)
          end
        end
      end

      def calculation_scheme_change
        return if @calculation_scheme.blank?

        if FeatureSwitching.calculation_scheme(calculation_scheme_data) != @calculation_scheme.to_sym
          if date_received != @object.date_received
            before_and_after_legislation_erorrs(date_received, :date_received)
          elsif date_fee_paid != @object.date_fee_paid
            before_and_after_legislation_erorrs(date_fee_paid, :date_fee_paid)
          end
        end
      end

      def calculation_scheme_data
        { date_received: date_received, date_fee_paid: date_fee_paid, refund: refund }
      end

      def before_and_after_legislation_erorrs(date, field_name)
        if date >= FeatureSwitching::NEW_BAND_CALCUATIONS_ACTIVE_DATE
          errors.add(field_name, 'This date cannot be on or after the new legislation')
        else
          errors.add(field_name, 'This date cannot be before the new legislation')
        end
      end
    end
  end
end
