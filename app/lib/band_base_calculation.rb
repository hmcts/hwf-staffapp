# frozen_string_literal: true

class BandBaseCalculation
  include BandCalculationHelper

  attr_reader :income, :fee, :saving_amount, :children_age_band,
              :married, :dob, :part_remission_amount, :amount_to_pay, :outcome

  def initialize(application)
    @income = application.income || 0
    @fee = application.detail.fee
    @saving_amount = application.saving.amount || 0
    @children_age_band = preformat_age_band(application)
    @married = application.applicant.married
    @dob = application.applicant.date_of_birth
  end

  def premiums_total
    @premiums_total ||= premiums
  end

  def saving_passed?
    @saving == true
  end

  def remission
    return outcome if savings_check.present?
    @saving = true

    income_to_use = calculate_income_to_use
    return outcome if outcome.present?
    @amount_to_pay = applicant_pays(income_to_use)

    @part_remission_amount = fee - @amount_to_pay
    @outcome = 'part'
  end

end
