# frozen_string_literal: true

class BandBaseCalculation
  attr_reader :income, :fee, :saving_amount, :children_age_band,
              :married, :dob, :part_remission_amount, :outcome

  MIN_THRESHOLD = 1420
  MAX_INCOME_THRESHOLD = 3000
  PREMIUM_BANDS = { 1 => 425, 2 => 710 }.freeze

  def initialize(application)
    @income = application.income || 0
    @fee = application.detail.fee
    @saving_amount = application.saving.amount || 0
    @children_age_band = preformat_age_band(application)
    @married = application.applicant.married
    @dob = application.applicant.date_of_birth
  end

  def saving_threshold_exceeded?
    case fee
    when 0..MIN_THRESHOLD
      saving_amount > 4250
    when 1421..5000
      saving_amount >= (fee * 3)
    when 5001..Float::INFINITY
      saving_amount > 16000
    end
  end

  def round_down_to_nearest_10(amount)
    return 0 if amount.negative?
    rounded = amount.round(-1)
    return rounded if rounded <= amount
    rounded - 10
  end

  def income_calculation(band, income)
    case band
    when 1
      income * 0.5
    when 2
      inc = income - 1000
      500 + (inc * 0.7)
    when 3
      inc = income - 2000
      1200 + (inc * 0.9)
    end
  end

  # no premium
  def income_band(income)
    case income
    when 0..MIN_THRESHOLD then 0
    when 1421..2420 then 1
    when 2421..3420 then 2
    when 3421..4420 then 3
    when 4421..Float::INFINITY then -1
    end
  end

  def premiums_total
    @premiums_total ||= premiums
  end

  def premiums
    @children_age_band << 2 if married
    children_age_band.sum do |age|
      PREMIUM_BANDS[age]
    end
  end

  def remission
    return outcome if savings_check.present?

    income_to_use = calculate_income_to_use
    return outcome if outcome.present?

    @part_remission_amount = fee - applicant_pays(income_to_use)
    @outcome = 'part'
  end

  private

  def calculate_income_to_use
    income_cap = MIN_THRESHOLD + premiums_total
    income_to_use = income - income_cap

    if premiums_total.positive?
      @outcome = 'full' if income_to_use_under_threshold?(income_to_use)
      @outcome = 'none' if income_to_use > MAX_INCOME_THRESHOLD
    else
      @band = income_band(income)
      @outcome = 'none' if @band == -1
    end
    income_to_use
  end

  def income_to_use_under_threshold?(income_to_use)
    income_to_use <= MIN_THRESHOLD || income_to_use.negative?
  end

  def applicant_pays(income_to_use)
    sum = if @band
            income_calculation(@band, income_to_use)
          else
            income_premium_calculation(income_to_use)
          end

    round_down_to_nearest_10(sum)
  end

  def income_premium_calculation(income_to_use)
    case income_to_use
    when 0..1420
      income_calculation(1, income_to_use)
    when 1421..2420
      income_calculation(2, income_to_use)
    when 2421..3420
      income_calculation(3, income_to_use)
    else
      income
    end
  end

  def savings_check
    if dob <= 66.years.ago
      @outcome = 'none' if saving_amount > 16000
    elsif saving_threshold_exceeded?
      @outcome = 'none'
    elsif income <= MIN_THRESHOLD
      @outcome = 'full'
    end
  end

  def preformat_age_band(application)
    age_band = []
    return age_band if application.children_age_band.blank?
    application.children_age_band.fetch(:one, 0).times { age_band << 1 }
    application.children_age_band.fetch(:two, 0).times { age_band << 2 }
    age_band
  end
end
