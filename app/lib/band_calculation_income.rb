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
      @outcome = 'full' if income_to_use_under_threshold?(income_to_use)
      @outcome = 'none' if income_to_use > BandBaseCalculation::MAX_INCOME_THRESHOLD
    else
      @band = income_band(income)
      @outcome = 'none' if @band == -1
    end
    income_to_use
  end

  def income_to_use_under_threshold?(income_to_use)
    income_to_use <= BandBaseCalculation::MIN_THRESHOLD || income_to_use.negative?
  end

  def applicant_pays(income_to_use)
    income_sum = if @band
                   income_calculation(@band, income_to_use)
                 else
                   income_premium_calculation(income_to_use)
                 end

    sum = income_sum || 0
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

end
