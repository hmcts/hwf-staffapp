class PersonalDataPurge
  # include deleted applications
  # completed_at < 7.year.ago
  attr_reader :applications_to_purge

  PURGE_STRING = 'data purged'.freeze

  def initialize
    load_applications
  end

  def purge!
    purge_personal_data
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
      online_benefit_check_purge!(application)
      application_purge!(application)
    end

    # deceased_name, date_of_death, case_number, ho_number, ni_number, title, first_name, last_name
    # address, email_address, phone

    # log_data_purge
  end

  def log_data_purge
    # audit_table_save
    # insights log
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

    online_application.update(purged: true, case_number: PURGE_STRING, date_of_death: PURGE_STRING,
      deceased_name: PURGE_STRING, title: PURGE_STRING, first_name: PURGE_STRING,
      last_name: PURGE_STRING, ni_number: PURGE_STRING, ho_number: PURGE_STRING,
      phone: PURGE_STRING, email_address: PURGE_STRING, address: PURGE_STRING, date_of_death: nil)
  end

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

  def online_benefit_check_purge!(application)
    online_application = application.online_application
    return unless online_application
    online_benefit_checks = online_application.online_benefit_checks
    return unless online_benefit_checks
    online_benefit_checks.update_all(parameter_hash: nil, our_api_token: nil, last_name: nil, ni_number: nil)
  end

end