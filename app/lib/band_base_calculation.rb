# frozen_string_literal: true

class BandBaseCalculation
  attr_reader :income, :fee, :saving_amount, :children_age_band, :married, :dob, :part_remission
  MIN_THRESHOLD = 1420
  MAX_INCOME_THRESHOLD = 3000


  def initialize(application)
    @income = application.income
    @fee = application.detail.fee
    @saving_amount = application.saving.amount
    @children_age_band = application.children_age_band || []
    @married = application.applicant.married
    @dob = application.applicant.date_of_birth
  end

  # -	Value of fee up to £1420: capital threshold = £4250,
  # -	Value of fee £1421 to £5000: capital threshold= 3x fee charged,
  # -	Value of fee £5001 or over: capital threshold= £16000.

  # Capital threshold
  # •	Minimum threshold = Band 1 (£4,250)
  # •	Maximum threshold = Band 3 (£16,00)
  # •	Where Savings & Investments Equal to or Less than Minimum threshold THEN banding applies - see below
  # •	Where Savings & Investments Greater than Minimum threshold but Less than Maximum threshold THEN banding applies - see below
  # •	Where Savings & Investments Greater than Maximum threshold THEN Not Eligible for help with fees

  def saving_threshold_exceeded?
    case fee
    when 0..MIN_THRESHOLD
      (saving_amount <= 4250) ? false : true
    when 1421..5000
      (saving_amount < (fee * 3)) ? false : true
    when 5001..Float::INFINITY
      (saving_amount <= 16000) ? false : true
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
      calc = 500
      calc += inc * 0.7
      calc
    when 3
      inc = income - 2000
      calc = 500 + 700
      calc += inc * 0.9
      calc
    end
  end

  # no premium
  def income_band(income)
    case income
    when 0..MIN_THRESHOLD
      return 0
    when 1421..2420
      1
    when 2421..3420
      2
    when 3421..4420
      3
    when 4421..Float::INFINITY
      -1
    end
  end


  def premiums
    premium_bands = {1 => 425, 2 => 710}
    total = 0
    total += 710 if married
    total += children_age_band.sum do |age|
      case age
      when 1, 2
        premium_bands[age]
      else
        0
      end
    end
    total
  end

  def remission
    if dob <= 66.years.ago
      return 'full' if saving_amount < 16000
      return 'none' if saving_amount > 16000
    end
    return 'none' if saving_threshold_exceeded?
    return 'full' if income <= MIN_THRESHOLD

    if premiums > 0
      income_cap = MIN_THRESHOLD + premiums
      income_to_use = income - income_cap
      return 'full' if income_to_use <= MIN_THRESHOLD || income_to_use.negative?
      return 'none' if MAX_INCOME_THRESHOLD < income_to_use
    else
      band = income_band(income)
      return 'none' if band == -1
      income_to_use = income - MIN_THRESHOLD
    end

    case income_to_use
    when 0..1420
      sum = income_calculation(1,income_to_use)
    when 1421..2420
      sum = income_calculation(2,income_to_use)
    when 2421..3420
      sum = income_calculation(3,income_to_use)
    else
      sum = income
    end
    sum = round_down_to_nearest_10(sum)
    @part_remission = fee - sum
    'part'
  end
end
