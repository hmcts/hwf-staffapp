class SpotcheckSelector
  def initialize(application)
    @application = application
  end

  def decide!
    @application.create_spotcheck if spotcheck?
  end

  private

  def spotcheck?
    if Application.spotcheckable.exists?(@application.id)
      @application.refund? ? check_every_other_refund : check_every_tenth_non_refund
    end
  end

  def check_every_other_refund
    get_spotcheck(2, true)
  end

  def check_every_tenth_non_refund
    get_spotcheck(10, false)
  end

  def get_spotcheck(frequency, refund)
    position = application_position(refund)
    (position > 1) && ((position % frequency) == 0)
  end

  def application_position(refund)
    Application.spotcheckable.where('id <= ? AND refund = ?', @application.id, refund).count
  end
end
