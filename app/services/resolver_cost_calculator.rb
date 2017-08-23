class ResolverCostCalculator
  def initialize(source)
    @source = source
    @application = @source.is_a?(Application) ? @source : @source.application
  end

  def cost
    ['return', 'none'].include?(@source.outcome) ? 0 : incurred_cost
  end

  private

  def incurred_cost
    if @source.is_a?(PartPayment)
      fee - amount_to_pay
    else
      fee
    end
  end

  def fee
    @application.detail.fee
  end

  def amount_to_pay
    if @application.evidence_check.present?
      @application.evidence_check.try(:amount_to_pay) || 0
    else
      @application.try(:amount_to_pay) || 0
    end
  end
end
