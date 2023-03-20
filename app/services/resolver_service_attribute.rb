module ResolverServiceAttribute

  private

  def completed_application_attributes
    completed_attributes.tap do |attrs|
      attrs.merge! BusinessEntityGenerator.new(@calling_object).attributes
      assign_new_reference_until_valid
    end
  end

  def assign_new_reference_until_valid
    if @calling_object.reference.blank?
      generator = ReferenceGenerator.new(@calling_object)
      @calling_object.reference = generator.attributes[:reference]

      return if @calling_object.validate(:reference)

      @calling_object.reference = generator.attributes[:reference] until @calling_object.validate(:reference)
    end
  end

  def completed_attributes
    { completed_at: @time, completed_by: @user }
  end

  def decided_attributes(source)
    {
      decision: lookup_decision(source.outcome),
      decision_type: derive_object(source),
      decision_date: @time,
      decision_cost: ResolverCostCalculator.new(source).cost,
      state: :processed
    }
  end

  def deleted_attributes
    { deleted_at: Time.zone.now, deleted_by: @user, state: :deleted }
  end

end
