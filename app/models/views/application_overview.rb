# coding: utf-8
module Views
  class ApplicationOverview
    attr_reader :application

    delegate(:amount_to_pay, to: :application)
    delegate(:full_name, to: :applicant)
    delegate(:form_name, :case_number, :deceased_name, :emergency_reason, to: :detail)

    def initialize(application)
      @application = application
    end

    def ni_number
      applicant.ni_number.gsub(/(.{2})/, '\1 ') unless applicant.ni_number.nil?
    end

    def status
      locale_scope = 'activemodel.attributes.forms/application/applicant'
      I18n.t("married_#{applicant.married?}", scope: locale_scope)
    end

    def jurisdiction
      detail.jurisdiction.name
    end

    def fee
      "£#{detail.fee.round}"
    end

    def date_of_birth
      format_date applicant.date_of_birth
    end

    def date_received
      format_date @application.date_received
    end

    def date_of_death
      format_date detail.date_of_death
    end

    def date_fee_paid
      format_date detail.date_fee_paid
    end

    def number_of_children
      @application.children
    end

    def total_monthly_income
      "£#{@application.income.round}" if @application.income
    end

    def benefits
      if type.eql?('benefit')
        return format_locale('passed_with_evidence') if benefit_override?
        format_locale(benefit_result) if @application.last_benefit_check
      end
    end

    def income
      format_locale(%w[full part].include?(result).to_s)
    end

    def savings
      format_locale(@application.saving.passed?.to_s)
    end

    def type
      @application.application_type
    end

    def result
      @application.outcome
    end

    def savings_investment_params
      if type.eql?('benefit')
        %w[savings benefits]
      elsif type.eql?('income')
        %w[savings income number_of_children total_monthly_income]
      else
        %w[savings]
      end
    end

    def processed_by
      @application.user.name
    end

    def reference
      @application.reference if evidence_check_or_part_payment?
    end

    def return_type
      {
        'evidence_check' => 'evidence',
        'part_payment' => 'payment'
      }[@application.decision_type] || nil
    end

    private

    def applicant
      @application.applicant
    end

    def detail
      @application.detail
    end

    def evidence_check_or_part_payment?
      @application.evidence_check.present? || @application.part_payment.present?
    end

    def format_locale(suffix)
      I18n.t(suffix, scope: 'activemodel.attributes.forms/application/summary')
    end

    def format_date(date)
      date.to_s(:gov_uk_long) if date
    end

    def benefit_result
      @application.last_benefit_check.dwp_result.eql?('Yes').to_s
    end

    def benefit_override?
      BenefitOverride.exists?(application_id: @application.id, correct: true)
    end
  end
end
