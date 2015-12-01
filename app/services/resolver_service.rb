class ResolverService
  def initialize(object, user)
    @calling_object = object
    @user = user
  end

  def process
    mark_complete
    evidence_check_and_payment if @calling_object.is_a?(Application)
    # TODO: implement evidence_check create for applications
    # TODO: implement payment creation for applications and evidence_checks
  end

  def resolve(outcome)
    record(outcome)
    record_decision_from(outcome)
    persist!
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

  def persist!
    ActiveRecord::Base.transaction do
      @calling_object.save
      @calling_object.application.save
    end
  end

  def mark_complete
    @calling_object.update_attributes(
      completed_by: @user,
      completed_at: Time.zone.now
    )
  end

  def derive_object
    @calling_object.class.name.underscore
  end

  def lookup_decision(outcome)
    { 'full' => 'full',
      'part' => 'part',
      'none' => 'none',
      'return' => 'none' }[outcome]
  end

  def evidence_check_and_payment
    EvidenceCheckSelector.new(@calling_object, Settings.evidence_check.expires_in_days).decide!
    PartPaymentBuilder.new(@calling_object, Settings.part_payment.expires_in_days).decide!
  end
end
