class SpotcheckSelector
  def initialize(application)
    @application = application
  end

  def decide!
    @application.create_spotcheck if spotcheck?
  end

  private

  def spotcheck?
    unless @application.benefits? || !%w[full part].include?(@application.application_outcome)
      if @application.refund?
        get_spotcheck(2, true)
      else
        get_spotcheck(10, false)
      end
    end
  end

  def get_spotcheck(frequency, refund)
    position = application_position(refund)
    (position > 1) && ((position % frequency) == 0)
  end

  def application_position(refund)
    values = [@application.id, refund]
    application_base_list.where('id <= ? AND refund = ?', *values).count
  end

  def application_base_list
    Application.
      where(benefits: false, application_type: 'income', application_outcome: %w[part full])
  end
end
