class PersonalDataPurge
  attr_reader :applications_to_purge

  PURGE_STRING = 'data purged'.freeze

  def initialize
    load_applications
  end

  def purge!
    app_insights_log
    purge_personal_data
    app_insights_log_end
  end

  private

  def load_applications
    @applications_to_purge ||= Application.where('completed_at < ?', Settings.personal_data_purge.years_ago.years.ago)
  end

  def purge_personal_data
    @applications_to_purge.each do |application|
      applicant_purge!(application)
      detail_purge!(application)
      online_application_purge!(application)
      hmrc_check_purge!(application)
      benefit_check_purge!(application)
      application_purge!(application)
      log_data_purge(application)
    end
  end

  def application_purge!(application)
    application.update(purged: true)
  end

  def applicant_purge!(application)
    applicant = application.applicant
    applicant.update(title: nil, first_name: nil, last_name: nil, ni_number: nil, ho_number: nil)
  end

  def detail_purge!(application)
    detail = application.detail
    detail.update(case_number: nil, date_of_death: nil, deceased_name: nil)
  end

  def online_application_purge!(application)
    online_application = application.online_application
    return unless online_application
    online_benefit_check_purge!(online_application)

    online_application.update(purged: true, case_number: PURGE_STRING,
                              deceased_name: PURGE_STRING, title: PURGE_STRING, first_name: PURGE_STRING,
                              last_name: PURGE_STRING, ni_number: PURGE_STRING, ho_number: PURGE_STRING,
                              phone: PURGE_STRING, email_address: PURGE_STRING, address: PURGE_STRING,
                              date_of_death: nil)
  end

  # rubocop:disable Rails/SkipsModelValidations
  # Update_all skips validations but following changes are not affecting any vailation
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

  def online_benefit_check_purge!(online_application)
    online_benefit_checks = online_application.online_benefit_checks
    return unless online_benefit_checks
    online_benefit_checks.update_all(parameter_hash: nil, our_api_token: nil, last_name: nil, ni_number: nil)
  end
  # rubocop:enable Rails/SkipsModelValidations

  # Logging
  def log_data_purge(application)
    AuditPersonalDataPurge.create(purged_date: Time.zone.today, application_reference_number: application.reference)
  end

  def app_insights_log
    tc = ApplicationInsights::TelemetryClient.new ENV.fetch('AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY', nil)
    tc.track_event("Running Personal data purge script: #{Time.zone.now.to_fs(:db)}")
    tc.flush
  end

  def app_insights_log_end
    tc = ApplicationInsights::TelemetryClient.new ENV.fetch('AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY', nil)
    tc.track_event("Finished personal data purge script: #{Time.zone.now.to_fs(:db)},
      applications affected: #{@applications_to_purge.count}")
    tc.flush
  end

end
