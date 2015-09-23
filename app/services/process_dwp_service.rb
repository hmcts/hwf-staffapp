class ProcessDwpService
  include ContactDwpHelper
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
    @response = JSON.parse(RestClient.post "#{ENV['DWP_API_PROXY']}/api/benefit_checks", params)
    fail Exceptions::UndeterminedDwpCheck if @response['benefit_checker_status'] == 'Undetermined'
    @result = true
  rescue Exceptions::UndeterminedDwpCheck
    log_error I18n.t('activerecord.attributes.dwp_check.undetermined'), 'Undetermined'
  rescue Errno::ECONNREFUSED
    log_error I18n.t('error_messages.dwp_checker.unavailable'), 'Server unavailable'
  rescue => e
    log_error(e.message, 'Unspecified error')
  end

  def log_error(message, result)
    @message = message
    @check_item.update!(dwp_result: result)
    LogStuff.log "dwp lookup", @message
  end
end
