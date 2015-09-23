class ProcessDwpService

  attr_accessor :result, :message, :response

  def initialize(dwp_check)
    @result = false
    @check_item = dwp_check
    check_remote_api
  end

  def result
    {
      success: @result,
      dwp_check: @check_item,
      message: @message
    }.to_json
  end

  private

  def check_remote_api
    @check_item.save!
    query_proxy_api
    if @result
      @check_item.dwp_result = @response['benefit_checker_status']
      @check_item.dwp_id = @response['confirmation_ref']
    end
    @check_item.benefits_valid = (@check_item.dwp_result == 'Yes' ? true : false)
    @check_item.save!
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
      id: @check_item.our_api_token,
      ni_number: @check_item.ni_number,
      surname: @check_item.last_name.upcase,
      birth_date: @check_item.dob.strftime('%Y%m%d'),
      entitlement_check_date: process_check_date
    }
  end

  def log_error(message, result)
    @message = message
    @check_item.update!(dwp_result: result)
    LogStuff.log "dwp lookup", @message
  end

  def process_check_date
    check_date = @check_item.date_to_check ? @check_item.date_to_check : Time.zone.today
    check_date.strftime('%Y%m%d')
  end
end
