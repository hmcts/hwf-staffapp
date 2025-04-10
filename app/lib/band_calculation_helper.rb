module BandCalculationHelper

  def saving_threshold_exceeded?
    case fee
    when 0..BandBaseCalculation::MIN_THRESHOLD
      saving_amount > 4250
    when 1420..5000
      saving_amount >= (fee * 3)
    when 5001..Float::INFINITY
      saving_amount > 15999
    end
  end

  def round_down_to_nearest_10(amount)
    return 0 if amount.negative?
    rounded = amount.round(-1)
    return rounded if rounded <= amount
    rounded - 10
  end

  def premiums
    children_premium = children_premium_calculation
    children_premium += BandBaseCalculation::PREMIUM_BAND_MARRIED if married
    children_premium
  end

  def children_premium_calculation
    children_age_band.sum do |age|
      BandBaseCalculation::PREMIUM_BANDS[age]
    end
  end

  def savings_check
    if over_66
      @outcome = 'none' if saving_amount > 16000
    elsif saving_threshold_exceeded?
      @outcome = 'none'
    elsif income <= BandBaseCalculation::MIN_THRESHOLD
      @outcome = 'full'
      @saving = true
    end
  end

  def preformat_age_band(application)
    @age_band = []
    return @age_band if application.children_age_band.blank?

    if application.children_age_band.keys.first.is_a?(String)
      online_appplication_band(application)
    else
      paper_appplication_band(application)
    end

    @age_band
  end

  def paper_appplication_band(application)
    application.children_age_band.fetch(:one, 0).times { @age_band << 1 }
    application.children_age_band.fetch(:two, 0).times { @age_band << 2 }
  end

  def online_appplication_band(application)
    application.children_age_band.fetch('one', 0).to_i.times { @age_band << 1 }
    application.children_age_band.fetch('two', 0).to_i.times { @age_band << 2 }
  end
end
