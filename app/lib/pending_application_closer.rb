# Closes an application still waiting on staff action when its personal data
# is purged, replicating the journey staff would have taken, acting as the
# purge user (Settings.personal_data_purge.user_id).
class PendingApplicationCloser
  PART_PAYMENT_CLOSE_REASON = 'Not processed in time at the time of data purge.'.freeze

  def initialize(application)
    @application = application
  end

  def close!
    if application.waiting_for_evidence?
      close_evidence_check
    elsif application.waiting_for_part_payment?
      close_part_payment
    end
  end

  private

  attr_reader :application

  # Replicates the staff return journey for evidence that never arrived or
  # arrived too late (Evidence::AccuracyFailedReasonController): record the
  # failed-accuracy answer on the evidence check, then resolve it as returned,
  # which moves the application to processed.
  def close_evidence_check
    evidence_check = application.evidence_check
    return unless evidence_check

    form = Forms::Evidence::Accuracy.new(evidence_check)
    form.update(correct: false, incorrect_reason: 'not_arrived_or_late')
    form.save
    ResolverService.new(evidence_check, purge_user).return
  end

  # Replicates the staff flow when "Is the part-payment ready to process?" is
  # answered "No" (PartPaymentsController#accuracy_save then #summary_save):
  # record the not-ready answer with the purge closure reason, then complete
  # the part payment, which moves the application to processed.
  def close_part_payment
    part_payment = application.part_payment
    return unless part_payment

    form = Forms::PartPayment::Accuracy.new(part_payment)
    form.update(correct: false, incorrect_reason: PART_PAYMENT_CLOSE_REASON)
    form.save
    ResolverService.new(part_payment, purge_user).complete
  end

  def purge_user
    @purge_user ||= User.find(Settings.personal_data_purge.user_id)
  end
end
