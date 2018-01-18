class ResolverService
  include ResolverServiceAttribute

  class UndefinedOutcome < StandardError; end
  class NotDeletable < StandardError; end

  def initialize(object, user)
    @calling_object = object
    @user = user
    @time = Time.zone.now
  end

  def complete
    check_outcome!
    ActiveRecord::Base.transaction do
      send("complete_#{derive_object(@calling_object)}", @calling_object)
    end
  end

  def return
    ActiveRecord::Base.transaction do
      @calling_object.update({ outcome: 'return' }.merge(completed_attributes))
      @calling_object.application.update(decided_attributes(@calling_object))
    end
  end

  def delete
    raise NotDeletable unless @calling_object.processed? && @calling_object.deleted_reason.present?
    ActiveRecord::Base.transaction do
      @calling_object.update(deleted_attributes)
    end
  end

  private

  def check_outcome!
    raise UndefinedOutcome if @calling_object.outcome.blank?
  end

  def complete_application(application)
    attributes = completed_application_attributes.tap do |attrs|

      if complete_because_discretion_applied?(application) ||
         application_state(application).nil?
        attrs.merge!(decided_attributes(application))
      elsif application_state(application).present?
        attrs[:state] = application_state(application)
      end
    end

    application.update!(attributes)
  end

  def application_state(application)
    if decide_evidence_check(application)
      :waiting_for_evidence
    elsif decide_part_payment(application)
      :waiting_for_part_payment
    end
  end

  def complete_evidence_check(evidence_check)
    evidence_check.update(completed_attributes)

    application_attributes = {}.tap do |attrs|
      if decide_part_payment(evidence_check)
        attrs[:state] = :waiting_for_part_payment
      else
        attrs.merge!(decided_attributes(evidence_check))
      end
    end
    evidence_check.application.update(application_attributes)
  end

  def complete_part_payment(part_payment)
    part_payment.update(completed_attributes)
    part_payment.application.update(decided_attributes(part_payment))
  end

  def derive_object(object)
    object.class.name.underscore
  end

  def lookup_decision(outcome)
    { 'full' => 'full', 'part' => 'part', 'none' => 'none', 'return' => 'none' }[outcome]
  end

  def decide_part_payment(application)
    @decide_part_payment ||= PartPaymentBuilder.new(
      application, Settings.part_payment.expires_in_days
    ).decide!
  end

  def decide_evidence_check(application)
    @decide_evidence_check ||= EvidenceCheckSelector.new(
      application, Settings.evidence_check.expires_in_days
    ).decide!
  end

  def complete_because_discretion_applied?(application)
    application.detail.discretion_applied == false
  end
end
