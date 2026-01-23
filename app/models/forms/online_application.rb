module Forms
  class OnlineApplication < FormObject
    include ActiveModel::Validations::Callbacks
    include DataFieldFormattable

    attr_reader :created_at

    # rubocop:disable Metrics/MethodLength
    def self.permitted_attributes
      { fee: :decimal,
        jurisdiction_id: :integer,
        date_received: :date,
        day_date_received: :integer,
        month_date_received: :integer,
        year_date_received: :integer,
        form_name: :string,
        case_number: :string,
        emergency: :boolean,
        emergency_reason: :string,
        benefits_override: :boolean,
        user_id: :integer,
        discretion_applied: :boolean,
        dwp_manual_decision: :boolean }
    end
    # rubocop:enable Metrics/MethodLength

    define_attributes

    before_validation :format_date_fields, :format_fee

    validates :fee, presence: true,
                    numericality: { allow_blank: true, greater_than_or_equal_to: 3, less_than: 20_000 }
    validates :jurisdiction_id, presence: true
    validates :case_number, presence: true, if: :refund?
    validates :emergency_reason, presence: true, if: :emergency?
    validates :emergency_reason, length: { maximum: 500 }

    validates :form_name, format: { with: /\A((?!EX160|COP44A).)*\z/i }, allow_nil: true
    validates :form_name, presence: true

    validates_with Validators::DateReceivedValidator

    def initialize(online_application)
      super
      @created_at = online_application.created_at
      self.emergency = true if emergency_reason.present?
    end

    def enable_default_jurisdiction(user)
      return if jurisdiction_id.present?
      self.jurisdiction_id = user.jurisdiction_id
    end

    def format_date_fields
      format_dates(:date_received) if format_the_dates?(:date_received)
    end

    def submitted_at
      @object.created_at
    end

    def reset_date_received_data
      @object.update(discretion_applied: nil, date_received: nil)
    end

    private

    def persist!
      @object.update(fields_to_update)
    end

    def fields_to_update
      fixed_fields.tap do |fields|
        fields[:emergency_reason] = (emergency ? emergency_reason : nil)
      end
    end

    # rubocop:disable Metrics/MethodLength
    def fixed_fields
      {
        fee: fee,
        jurisdiction_id: jurisdiction_id,
        date_received: date_received,
        form_name: form_name,
        case_number: case_number,
        benefits_override: benefits_override,
        user_id: user_id,
        discretion_applied: discretion_applied,
        dwp_manual_decision: dwp_manual_decision
      }
    end
    # rubocop:enable Metrics/MethodLength

    def format_fee
      self.fee = fee.strip.to_f if fee.is_a?(String) && fee.strip.to_f.positive?
    end

    def refund?
      @object.refund?
    end
  end
end
