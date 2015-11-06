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

  private

  def mark_complete
    @calling_object.update_attributes(
      completed_by: @user,
      completed_at: Time.zone.now
    )
  end
end
