class PersonalDataPurge
  attr_reader :applications_to_purge

  PURGE_STRING = 'data purged'.freeze

  def initialize(applications_to_purge)
    @applications_to_purge = applications_to_purge
  end

  def purge!
    purge_personal_data
  end

  def purge_online_only!
    @applications_to_purge.each do |online_application|
      online_application_purge!(online_application)
      log_data_purge(online_application)
    end
  end

  private

  def purge_personal_data
    @applications_to_purge.each do |application|
      applicant_purge!(application)
      detail_purge!(application)
      online_application_purge!(application.online_application)
      hmrc_check_purge!(application)
      benefit_check_purge!(application)
      application_purge!(application)
      log_data_purge(application)
      close_pending_applications(application)
    end
  end

  def application_purge!(application)
    # This method raising DEPRECATION WARNING: for Date#to_s this is because of paranoia gem (I think).
    application.update(purged: true, purged_at: Time.zone.now)
  end

  def applicant_purge!(application)
    applicant = application.applicant
    applicant.update(title: nil, first_name: nil, last_name: nil, ni_number: nil, ho_number: nil)
  end

  def detail_purge!(application)
    detail = application.detail
    detail.update(case_number: nil, date_of_death: nil, deceased_name: nil)
  end

  def online_application_purge!(online_application)
    return unless online_application
    benefit_check_purge!(online_application)

    online_application.update(purged: true, purged_at: Time.zone.now, case_number: PURGE_STRING,
                              deceased_name: PURGE_STRING, title: PURGE_STRING, first_name: PURGE_STRING,
                              last_name: PURGE_STRING, ni_number: PURGE_STRING, ho_number: PURGE_STRING,
                              phone: PURGE_STRING, email_address: PURGE_STRING, address: PURGE_STRING,
                              date_of_death: nil)
  end

  # rubocop:disable Rails/SkipsModelValidations
  # Update_all skips validations but following changes are not affecting any validation
  # in those models.

  def hmrc_check_purge!(application)
    hmrc_checks = application.evidence_check.try(:hmrc_checks)
    return unless hmrc_checks
    hmrc_checks.update_all(address: nil, ni_number: nil)
  end

  def benefit_check_purge!(application)
    benefit_checks = application.benefit_checks
    return unless benefit_checks
    benefit_checks.update_all(parameter_hash: nil, our_api_token: nil, last_name: nil, ni_number: nil)
  end

  # rubocop:enable Rails/SkipsModelValidations

  def close_pending_applications(application)
    if application.waiting_for_evidence?
      close_evidence_check(application)
    elsif application.waiting_for_part_payment?
      close_part_payment(application)
    end
  end

  # Logging
  def log_data_purge(application)
    AuditPersonalDataPurge.create(purged_date: Time.zone.today, application_reference_number: application.reference)
  end

  # Replicates the staff return journey for evidence that never arrived or
  # arrived too late (Evidence::AccuracyFailedReasonController): record the
  # failed-accuracy answer on the evidence check, then resolve it as returned,
  # which moves the application to processed.
  def close_evidence_check(application)
    evidence_check = application.evidence_check
    return unless evidence_check

    form = Forms::Evidence::Accuracy.new(evidence_check)
    form.update(correct: false, incorrect_reason: 'not_arrived_or_late')
    form.save
    ResolverService.new(evidence_check, purge_user).return
  end

  def close_part_payment(application)
    # TODO: close the pending part payment via the return journey, as the
    # purge user (Settings.personal_data_purge.user_id)
  end

  def purge_user
    @purge_user ||= User.find(Settings.personal_data_purge.user_id)
  end

end
