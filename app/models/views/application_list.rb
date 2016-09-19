module Views
  class ApplicationList
    include ActionView::Helpers::NumberHelper

    attr_reader :application, :evidence_or_part_payment

    def initialize(calling_object)
      if calling_object.is_a?(Application)
        @application = calling_object
      else
        @evidence_or_part_payment = calling_object
        @application = calling_object.application
      end
    end

    def id
      @application.id
    end

    def reference
      @application.reference
    end

    def applicant
      @application.applicant.full_name
    end

    def date_received
      @application.detail.date_received.to_s(:gov_uk_short)
    end

    def processed_by
      @application.completed_by.try(:name)
    end

    def processed_on
      @application.completed_at.try(:strftime, Date::DATE_FORMATS[:gov_uk_short])
    end

    def form_name
      @application.detail.form_name
    end

    def fee
      number_to_currency(@application.detail.fee, unit: '£', precision: 0)
    end

    def emergency
      convert_tick_nil(@application.detail.emergency_reason.present?.to_s)
    end

    def part_payment?
      convert_tick_nil(@application.part_payment.present?)
    end

    def evidence_check?
      convert_tick_nil(@application.evidence_check.present?)
    end

    def paper_application?
      convert_tick_nil(@application.online_application.nil?)
    end

    def other
      result = []
      result << 'Emergency' if @application.detail.emergency_reason.present?
      result << 'Granted' if @application.decision_override.present?
      result << 'Refund' if @application.detail.refund
      result.join('<br />')
    end

    private

    def convert_tick_nil(value)
      I18n.t(value.to_s, scope: 'convert_tick_nil')
    end
  end
end
