module Forms
  module Application
    class Detail < ::FormObject

      TIME_LIMIT_FOR_PROBATE = 20

      # rubocop:disable MethodLength
      def self.permitted_attributes
        { fee: Integer,
          jurisdiction_id: Integer,
          date_received: Date,
          probate: Boolean,
          date_of_death: Date,
          deceased_name: String,
          refund: Boolean,
          emergency: Boolean,
          emergency_reason: String,
          date_fee_paid: Date,
          form_name: String,
          case_number: String }
      end

      define_attributes

      validates :fee, numericality: { allow_blank: true }
      validates :fee, presence: true
      validates :jurisdiction_id, presence: true
      validate :reason
      validate :emergency_reason_size

      validates :date_received, date: {
        after_or_equal_to: :min_date,
        before: :tomorrow
      }

      with_options if: :probate? do
        validates :deceased_name, presence: true
        validates :date_of_death, date: {
          after_or_equal_to: :min_probate,
          before: :tomorrow
        }
      end

      with_options if: :validate_date_fee_paid? do
        validates :date_fee_paid, date: {
          before_or_equal_to: :max_refund_date,
          allow_blank: false
        }
      end

      private

      def min_probate
        TIME_LIMIT_FOR_PROBATE.years.ago
      end

      def min_date
        3.months.ago.midnight
      end

      def max_refund_date
        date_received if date_received.present?
      end

      def validate_date_fee_paid?
        refund? && (date_received.is_a?(Date) || date_received.is_a?(Time))
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
        self.emergency_reason = nil if emergency_reason.blank?
      end

      def persist!
        @object.update(fields_to_update)
      end

      def fields_to_update
        {}.tap do |fields|
          (self.class.permitted_attributes.keys - [:emergency]).each do |name|
            fields[name] = send(name)
          end
        end
      end
    end
  end
end
