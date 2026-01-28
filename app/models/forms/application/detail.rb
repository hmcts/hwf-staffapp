module Forms
  module Application
    class Detail < ::FormObject
      include ActiveModel::Validations::Callbacks
      include DataFieldFormattable
      include RefundValidatable
      include DateFieldsValidatable

      # rubocop:disable Metrics/MethodLength
      def self.permitted_attributes
        { fee: :decimal,
          jurisdiction_id: :integer,
          date_received: :date,
          day_date_received: :integer,
          month_date_received: :integer,
          year_date_received: :integer,
          probate: :boolean,
          date_of_death: :date,
          day_date_of_death: :integer,
          month_date_of_death: :integer,
          year_date_of_death: :integer,
          deceased_name: :string,
          refund: :boolean,
          emergency: :boolean,
          emergency_reason: :string,
          date_fee_paid: :date,
          day_date_fee_paid: :integer,
          month_date_fee_paid: :integer,
          year_date_fee_paid: :integer,
          form_name: :string,
          case_number: :string,
          discretion_applied: :boolean,
          discretion_manager_name: :string,
          discretion_reason: :string,
          statement_signed_by: :string }
      end
      # rubocop:enable Metrics/MethodLength

      define_attributes

      before_validation :format_date_fields
      after_validation :check_discretion
      after_validation :check_refund_values

      validates :fee, presence: true,
                      numericality: { allow_blank: true, less_than: 20_000, greater_than_or_equal_to: 3 }
      validates :jurisdiction_id, presence: true
      validates :case_number, presence: true, if: proc { |detail| detail.refund? }
      validates :discretion_manager_name,
                :discretion_reason, presence: true, if: proc { |detail| detail.discretion_applied }

      validate :validate_date_received
      validates :date_received, comparison: { less_than: :tomorrow, message: :date_before }, if: :date_received_is_date?

      validates :form_name, format: { with: /\A((?!EX160|COP44A).)*\z/i }, allow_nil: true
      validates :form_name, presence: true

      with_options if: :probate? do
        validates :deceased_name, presence: true
        validate :validate_date_of_death
        validates :date_of_death, comparison: { less_than: :tomorrow, message: :date_before },
                                  if: :date_of_death_is_date?
      end

      validate :reason
      validate :emergency_reason_size

      def format_date_fields
        [:date_received, :date_of_death, :date_fee_paid].each do |key|
          format_dates(key) if format_the_dates?(key)
        end
      end

      private

      def min_date
        3.months.ago.midnight
      end

      def tomorrow
        Time.zone.tomorrow
      end

      def reason
        if emergency_without_reason?
          errors.add(
            :emergency_reason,
            :cant_have_emergency_reason_without_emergency
          )
        end

        format_reason
      end

      def emergency_without_reason?
        emergency? && emergency_reason.blank?
      end

      def emergency_reason_present_and_too_long?
        emergency_reason.present? && emergency_reason.size > 500
      end

      def emergency_reason_size
        if emergency_reason_present_and_too_long?
          errors.add(
            :emergency_reason,
            :too_long
          )
        end
      end

      def format_reason
        self.emergency_reason = nil if emergency_reason.blank? || emergency == false
      end

      def persist!
        clear_unused_data
        @object.update(fields_to_update)
      end

      def fields_to_update
        excluded_keys = [:emergency,
                         :day_date_received, :month_date_received, :year_date_received,
                         :day_date_of_death, :month_date_of_death, :year_date_of_death,
                         :day_date_fee_paid, :month_date_fee_paid, :year_date_fee_paid]
        {}.tap do |fields|
          (self.class.permitted_attributes.keys - excluded_keys).each do |name|
            fields[name] = send(name)
          end
        end
      end

      def clear_unused_data
        format_probate
      end
    end
  end
end
