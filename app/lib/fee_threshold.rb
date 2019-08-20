class FeeThreshold
  FEE_BANDS =
    [
      { lower: 1001, upper: 1335, amount: 4000 },
      { lower: 1336, upper: 1665, amount: 5000 },
      { lower: 1666, upper: 2000, amount: 6000 },
      { lower: 2001, upper: 2330, amount: 7000 },
      { lower: 2331, upper: 4000, amount: 8000 },
      { lower: 4001, upper: 5000, amount: 10000 },
      { lower: 5001, upper: 6000, amount: 12000 },
      { lower: 6001, upper: 7000, amount: 14000 }
    ].freeze

  def initialize(fee)
    return if fee.nil?
    @fee = fee.round
  end

  def band
    return if @fee.nil?
    return 3000 if @fee <= 1000
    return 16000 if @fee >= 7001
    FEE_BANDS.each do |band|
      result = find_band band
      return result unless result.nil?
    end
  end

  private

  def find_band(line)
    amount, lower, upper = get_band_values(line)
    amount if @fee.between?(lower, upper)
  end

  def get_band_values(line)
    [line[:amount], line[:lower], line[:upper]]
  end
end
