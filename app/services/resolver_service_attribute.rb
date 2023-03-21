module ResolverServiceAttribute
  MAX_NUMBER_OF_ATTEMPTS = 10

  private

  def completed_application_attributes
    completed_attributes.tap do |attrs|
      attrs.merge! BusinessEntityGenerator.new(@calling_object).attributes
      reference_saved = nil
      iterations = 0
      next if @calling_object.reference.present?
      until reference_saved == true || iterations > MAX_NUMBER_OF_ATTEMPTS
        iterations += 1
        reference_saved = assign_new_reference_until_valid
      end
    end
  end

  def assign_new_reference_until_valid
    generator = ReferenceGenerator.new(@calling_object)
    @calling_object.reference = generator.attributes[:reference]
    @calling_object.save
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::StatementInvalid
    false
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
