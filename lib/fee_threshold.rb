class FeeThreshold
  def initialize(application)
    @application = application
  end

  def band
    return 3000 if fee <= 1000
    return 4000 if fee.between?(1001, 1335)
    return 5000 if fee.between?(1336, 1665)
    return 6000 if fee.between?(1666, 2000)
    return 7000 if fee.between?(2001, 2330)
    return 8000 if fee.between?(2331, 4000)
    return 10000 if fee.between?(4001, 5000)
    return 12000 if fee.between?(5001, 6000)
    return 14000 if fee.between?(6001, 7000)
    return 16000 if fee >= 7001
  end

  private

  def fee
    @application.fee
  end
end
