module NotifyMailerHelper
  include ActionView::Helpers::NumberHelper
  include IncomePeriodHelper

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def to_h(application)
    {
      application_reference_code: format_opt(application.reference),
      application_form_name: format(application.form_name),
      application_fee_paid: format(application.refund),
      application_ni_number: format_opt(application.ni_number),
      application_status: married_status_text(application),
      application_savings_and_investments: format_opt(savings_text(application)),
      application_benefits: benefits_text(application),
      application_children: children_text(application),
      application_income_amount: format_opt(income_amount_text(application)),
      application_income_period: format_opt(income_period(application)&.capitalize),
      application_income_type: format_opt(income_kind_text(application)),
      application_probate: format(application.probate),
      application_claim_number: format(application.case_number),
      application_date_of_birth: format_opt(dob_text(application)),
      application_first_name: format_opt(application.first_name),
      application_last_name: format_opt(application.last_name),
      application_address: format_opt(application.address),
      application_postcode: format_opt(application.postcode),
      application_email: format_opt(application.email_address),
      application_declaration: declaration_text(application),
      application_applying_method: applying_method_text(application)
    }
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  private

  def married_status_text(application)
    scope = 'activemodel.attributes.forms/application/applicant'

    application.married ? I18n.t('married_true', scope: scope) : I18n.t('married_false', scope: scope)
  end

  def savings_text(application)
    scope = 'activemodel.attributes.views/overview/savings_and_investments'

    if !application.min_threshold_exceeded?
      I18n.t('less_then', scope: scope)
    elsif application.max_threshold_exceeded?
      I18n.t('more_then', scope: scope)
    elsif application.over_66?
      I18n.t('between', scope: scope)
    else
      number_to_currency(application.amount, unit: '£', precision: 0)
    end
  end

  def benefits_text(application)
    application.benefits ? I18n.t('email.confirmation.true') : I18n.t('email.confirmation.benefits_false')
  end

  def children_text(application)
    application.children&.zero? ? I18n.t('email.confirmation.false') : format(application.children)
  end

  def income_amount_text(application)
    number_to_currency(application.income, unit: '£', precision: 0)
  end

  def income_kind_text(application)
    application.income_kind[:applicant]&.join(', ')
  end

  def dob_text(application)
    application.date_of_birth.to_fs(:default)
  end

  def declaration_text(application)
    scope = 'email.confirmation'

    if application.statement_signed_by == 'applicant'
      I18n.t('statement_signed_by_applicant', scope: scope)
    else
      I18n.t('statement_signed_by_representative', scope: scope)
    end
  end

  def applying_method_text(application)
    if application.applying_method == "online"
      I18n.t('email.confirmation.online.applying_method')
    else
      I18n.t('email.confirmation.paper.applying_method')
    end
  end

  def format(value)
    value || I18n.t('email.confirmation.false')
  end

  def format_opt(value)
    value || I18n.t('email.confirmation.none')
  end
end
