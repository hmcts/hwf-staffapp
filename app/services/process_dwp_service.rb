class ProcessDwpService

  attr_accessor :result, :message, :response

  def initialize(dwp_check)
    @result = false
    @dwp_checker = dwp_check
    check_remote_api
  end

  def result
    {
      success: @result,
      dwp_check: @dwp_checker,
      message: @message
    }.to_json
  end

  private

  def check_remote_api
    @dwp_checker.save!
    query_proxy_api
    if @result
      @dwp_checker.dwp_result = @response['benefit_checker_status']
      @dwp_checker.dwp_id = @response['confirmation_ref']
    end
    @dwp_checker.benefits_valid = (@dwp_checker.dwp_result == 'Yes' ? true : false)
    @dwp_checker.save!
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
      id: @dwp_checker.our_api_token,
      ni_number: @dwp_checker.ni_number,
      surname: @dwp_checker.last_name.upcase,
      birth_date: @dwp_checker.dob.strftime('%Y%m%d'),
      entitlement_check_date: process_check_date
    }
  end

  def log_error(message, result)
    @message = message
    @dwp_checker.update!(dwp_result: result)
    LogStuff.log "dwp lookup", @message
  end

  def process_check_date
    check_date = @dwp_checker.date_to_check ? @dwp_checker.date_to_check : Time.zone.today
    check_date.strftime('%Y%m%d')
  end
end
