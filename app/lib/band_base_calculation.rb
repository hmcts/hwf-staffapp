# frozen_string_literal: true

class BandBaseCalculation
  include BandCalculationHelper
  include BandCalculationIncome

  MIN_THRESHOLD = 1420
  MAX_INCOME_THRESHOLD = 3000
  PREMIUM_BANDS = { 1 => 425, 2 => 710 }.freeze
  PREMIUM_BAND_MARRIED = 710

  attr_reader :income, :fee, :saving_amount, :children_age_band,
              :married, :over_66, :part_remission_amount, :amount_to_pay, :outcome

  def initialize(application)
    @amount_to_pay = 0
    load_paper_application_values(application) if application.is_a?(Application)
    load_online_application_values(application) if application.is_a?(OnlineApplication)
  end

  def premiums_total
    @premiums_total ||= premiums
  end

  def saving_passed?
    @saving == true
  end

  def income_failed?
    @saving == true && @outcome == 'none'
  end

  def remission
    return outcome if savings_check.present?
    @saving = true

    income_to_use = calculate_income_to_use
    return outcome if outcome.present?
    @amount_to_pay = applicant_pays(income_to_use)

    decide_part_remission
  end

  def load_paper_application_values(application)
    @income = application.income || 0
    @fee = application.detail.fee
    @saving_amount = application.saving.amount || 0
    @children_age_band = preformat_age_band(application)
    @married = application.applicant.married
    @over_66 = application.saving.over_66
  end

  def load_online_application_values(application)
    @income = application.income || 0
    @fee = application.fee
    @saving_amount = online_saving_amount(application)
    @children_age_band = preformat_age_band(application)
    @married = application.married
    @over_66 = application.over_66
  end

  def online_saving_amount(application)
    return Settings.savings_threshold.maximum_value if application.max_threshold_exceeded == true
    application.amount || 0
  end

  def decide_part_remission
    @part_remission_amount = fee - @amount_to_pay

    if @part_remission_amount.positive? && @amount_to_pay.positive?
      set_part_remission
    elsif @amount_to_pay.zero?
      @outcome = 'full'
    else
      set_no_remission
    end
  end

  def set_part_remission
    @outcome = 'part'
  end

  def set_no_remission
    @amount_to_pay = fee
    @outcome = 'none'
  end

end
