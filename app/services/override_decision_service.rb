class OverrideDecisionService

  def initialize(application, decision_override)
    @application = application
    @decision_override = decision_override
  end

  def set!
    @decision_override.save
    update_application
    @application.save
  end

  private

  def update_application
    @application.update_attributes(
      decision: 'full',
      decision_type: 'override',
      decision_cost: @application.detail.fee
    )
  end
end
