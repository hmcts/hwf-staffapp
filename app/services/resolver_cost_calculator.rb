class ResolverCostCalculator
  def initialize(source)
    @source = source
  end

  def cost
    @source.outcome == 'none' ? 0 : incurred_cost(@source)
  end

  private

  def incurred_cost(source)
    if source.is_a?(PartPayment)
      if source.application.evidence_check.present?
        fee(source) - amount_to_pay(source.application.evidence_check)
      else
        fee(source) - amount_to_pay(source.application)
      end
    else
      fee(source)
    end
  end

  def fee(source)
    if source.is_a?(Application)
      source.detail.fee
    else
      source.application.detail.fee
    end
  end

  def amount_to_pay(source)
    source.try(:amount_to_pay) || 0
  end
end
