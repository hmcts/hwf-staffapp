# coding: utf-8

module Views

  class ApplicationResult

    def initialize(application)
      @application = application
    end

    def result
      ['granted', 'full', 'part', 'paid', 'none', 'return'].include?(outcome) ? outcome : 'error'
    end

    def amount_to_pay
      # Because we are outside the ActiveRecord::Base scope I can't use is_a?
      if outcome_from.class.name.to_s == 'PartPayment'
        to_pay = amount_to_pay_for_part_payment
        "£#{parse_amount_to_pay(to_pay.to_i)}"
      elsif outcome_from.amount_to_pay.present?
        "£#{parse_amount_to_pay(outcome_from.amount_to_pay)}"
      end
    end

    def amount_to_pay_for_part_payment
      if @application.evidence_check
        @application.evidence_check.amount_to_pay
      else
        @application.amount_to_pay
      end
    end

    def parse_amount_to_pay(amount_to_pay)
      amount_to_pay % 1 != 0 ? amount_to_pay : amount_to_pay.to_i
    end

    def savings
      format_locale(@application.saving.passed?.to_s)
    end

    def income
      format_locale(['full', 'part'].include?(result).to_s)
    end

    def refund
      @application.detail.refund?
    end

    def amount_to_refund
      @application.detail.fee - amount_to_pay_for_part_payment
    end

    def state
      @application.state
    end

    def return_type
      {
        'evidence_check' => 'evidence',
        'part_payment' => 'payment'
      }[@application.decision_type] || nil
    end

    private

    def outcome
      case outcome_from.class.name
      when 'EvidenceCheck'
        outcome_from.outcome
      when 'PartPayment'
        outcome_from_application
      when 'Application'
        outcome_from_application
      end
    end

    def outcome_from_application
      if @application.decision_override.present?
        'granted'
      elsif part_payment_successful
        'paid'
      else
        @application.outcome
      end
    end

    def part_payment_successful
      @application.part_payment&.correct?
    end

    def outcome_from
      @application.part_payment || @application.evidence_check || @application
    end

    def format_locale(suffix)
      prefix = 'activemodel.attributes.forms/application/summary'
      I18n.t(suffix, scope: prefix)
    end
  end
end
