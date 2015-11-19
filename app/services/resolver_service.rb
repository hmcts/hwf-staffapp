class ResolverService
  def initialize(object, user)
    @calling_object = object
    @user = user
  end

  def process
    mark_complete
    process_evidence_check if @calling_object.is_a? EvidenceCheck
    # TODO: implement evidence_check create for applications
    # TODO: implement payment creation for applications and evidence_checks
  end

  private

  def process_evidence_check
    if @calling_object.outcome.eql?('returned')
      @calling_object.application.assign_attributes(application_type: 'returned', outcome: 'none')
    end
  end

  def mark_complete
    @calling_object.update_attributes(
      completed_by: @user,
      completed_at: Time.zone.now
    )
  end
end
