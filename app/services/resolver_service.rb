class ResolverService
  def initialize(object, user)
    @calling_object = object
    @user = user
  end

  def process
    mark_complete
    # TODO: implement evidence_check create for applications
    # TODO: implement payment creation for applications and evidence_checks
  end

  def resolve(outcome)
    record(outcome)
    record_decision_from(outcome)
    @calling_object.save
  end

  private

  def record(outcome)
    @calling_object.assign_attributes(outcome: outcome,
                                      completed_by: @user,
                                      completed_at: Time.zone.now)
  end

  def record_decision_from(outcome)
    @calling_object.application.assign_attributes(decision: lookup_decision(outcome),
                                                  decision_type: derive_object)
  end

  def mark_complete
    @calling_object.update_attributes(
      completed_by: @user,
      completed_at: Time.zone.now
    )
  end

  def evidence_check
    { 'full' => 'full',
      'part' => 'part',
      'none' => 'none',
      'return' => 'none' }
  end

  def part_payment
    { 'return' => 'none',
      'none' => 'none',
      'part' => 'part' }
  end

  def derive_object
    @calling_object.class.name.underscore
  end

  def lookup_decision(outcome)
    send(derive_object)[outcome]
  end
end
