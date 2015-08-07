class BenefitCheckService

  attr_accessor :result, :message, :response

  def initialize(benefit_check)
    @result = false
    @benefit_check = benefit_check
    begin
      validate_inputs
      check_remote_api
    rescue
      @benefit_check.benefits_valid = @result
      log_error I18n.t('activerecord.attributes.dwp_check.undetermined'), 'Undetermined'
    end
  end

  private

  def validate_inputs
    set_params.values.all?
  end

  def check_remote_api
    @benefit_check.save!
    query_proxy_api
    if @result
      @benefit_check.dwp_result = @response['benefit_checker_status']
      @benefit_check.dwp_api_token = @response['confirmation_ref']
    end
    @benefit_check.benefits_valid = (@benefit_check.dwp_result == 'Yes' ? true : false)
    @benefit_check.save!
  end

  def query_proxy_api
    @response = JSON.parse(RestClient.post "#{ENV['DWP_API_PROXY']}/api/benefit_checks", set_params)
    fail Exceptions::UndeterminedDwpCheck if @response['benefit_checker_status'] == 'Undetermined'
    @result = true
  rescue Exceptions::UndeterminedDwpCheck
    log_error I18n.t('activerecord.attributes.dwp_check.undetermined'), 'Undetermined'
  rescue Errno::ECONNREFUSED
    log_error I18n.t('error_messages.dwp_checker.unavailable'), 'Server unavailable'
  rescue => e
    log_error(e.message, 'Unspecified error')
  end

  def set_params
    {
      id: @benefit_check.our_api_token,
      ni_number: @benefit_check.ni_number,
      surname: @benefit_check.last_name.upcase,
      birth_date: @benefit_check.date_of_birth.strftime('%Y%m%d'),
      entitlement_check_date: process_check_date
    }
  end

  def log_error(message, result)
    @benefit_check.error_message = message
    @benefit_check.update!(dwp_result: result)
    LogStuff.log 'Benefit check', message
  end

  def process_check_date
    check_date = @benefit_check.date_to_check ? @benefit_check.date_to_check : Time.zone.today
    check_date.strftime('%Y%m%d')
  end
end
