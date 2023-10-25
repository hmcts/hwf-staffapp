module Forms
  module Application
    class FeeStatus < ::FormObject
      include ActiveModel::Validations::Callbacks
      include DataFieldFormattable
      include RefundValidatable

      TIME_LIMIT_FOR_PROBATE = 20

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
      after_validation :check_discretion
      after_validation :check_refund_values
      after_validation :update_calculation_scheme

      validates :discretion_manager_name,
                :discretion_reason, presence: true, if: proc { |detail| detail.discretion_applied }
      validates :refund, inclusion: { in: [true, false] }

      validates :date_received, date: {
        after_or_equal_to: :min_date,
        before: :tomorrow
      }

      validates :date_fee_paid, presence: true, if: proc { |detail| detail.refund }
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
        self.calculation_scheme = FeatureSwitching.calculation_scheme(@object.application)
      end

      def min_date
        3.months.ago.midnight
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
        # binding.pry

        if FeatureSwitching.calculation_scheme(@object.application) != @calculation_scheme.to_sym
          if date_received != @object.date_received
            errors.add(:date_received, 'This date cannot be before the new legislation')
          elsif date_fee_paid != @object.date_fee_paid
            errors.add(:date_fee_paid, 'This date cannot be on or after the new legislation')
          end
        end
      end
    end
  end
end
