class SpotcheckSelector
  def initialize(application)
    @application = application
  end

  def decide!
    @application.create_spotcheck if spotcheck?
  end

  private

  def spotcheck?
    if @application.benefits?
      false
    else
      if @application.refund?
        get_spotcheck(2, true)
      else
        get_spotcheck(10, false)
      end
    end
  end

  def get_spotcheck(frequency, refund)
    (application_position(refund) % frequency) == 0
  end

  def application_position(refund)
    values = [@application.id, false, refund]
    Application.where('id <= ? AND benefits = ? AND refund = ?', *values).count
  end
end
