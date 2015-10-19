module Applikation
  module Forms
    class ApplicationDetail < ::FormObject

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
        after: proc { Time.zone.today - 3.months },
        before: proc { Time.zone.today + 1.day }
      }

      with_options if: :probate? do
        validates :deceased_name, presence: true
        validates :date_of_death, date: {
          after: proc { Time.zone.today - TIME_LIMIT_FOR_PROBATE.years },
          before: proc { Time.zone.today + 1.day }
        }
      end

      with_options if: :refund? do
        validates :date_fee_paid, date: {
          after: proc { Time.zone.today - 3.months },
          before: proc { Time.zone.today + 1.day }
        }
      end

      private

      def reason
        errors.add(
          :emergency_reason,
          :cant_have_emergency_reason_without_emergency
        ) if emergency_without_reason?
        format_reason
      end

      def emergency_without_reason?
        emergency? && emergency_reason.blank?
      end

      def emergency_reason_present_and_too_long?
        !emergency_reason.blank? && emergency_reason.size > 500
      end

      def emergency_reason_size
        errors.add(
          :emergency_reason,
          :too_long
        ) if emergency_reason_present_and_too_long?
      end

      def format_reason
        self.emergency_reason = nil if emergency_reason.blank?
      end
    end
  end
end
