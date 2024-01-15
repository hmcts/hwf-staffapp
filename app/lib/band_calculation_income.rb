module BandCalculationIncome

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
    when 0..BandBaseCalculation::MIN_THRESHOLD then 0
    when 1421..2420 then 1
    when 2421..3420 then 2
    when 3421..4420 then 3
    when 4421..Float::INFINITY then -1
    end
  end

  private

  def calculate_income_to_use
    income_cap = BandBaseCalculation::MIN_THRESHOLD + premiums_total
    income_to_use = income - income_cap

    if premiums_total.positive?
      apply_premiums(income_to_use)
    else
      no_premiums(income)
    end
    income_to_use
  end

  def no_premiums(income)
    @band = income_band(income)
    if @band == -1
      @outcome = 'none'
      @amount_to_pay = fee
    end
  end

  def apply_premiums(income_to_use)
    @outcome = 'full' if income_to_use.negative?
    if income_to_use > BandBaseCalculation::MAX_INCOME_THRESHOLD
      @amount_to_pay = fee
      @outcome = 'none'
    end
  end

  def applicant_pays(income_to_use)
    income_rounded = round_down_to_nearest_10(income_to_use)
    income_sum = if @band
                   income_calculation(@band, income_rounded)
                 else
                   income_premium_calculation(income_rounded)
                 end

    income_sum || 0
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

end
