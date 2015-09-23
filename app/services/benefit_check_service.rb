class BenefitCheckService
  include ContactDwpHelper
  attr_accessor :result, :message, :response

  def initialize(benefit_check)
    @result = false
    @check_item = benefit_check
    begin
      validate_inputs
      check_remote_api
    rescue
      @check_item.benefits_valid = @result
      log_error I18n.t('activerecord.attributes.dwp_check.undetermined'), 'Undetermined'
    end
  end

  private

  def validate_inputs
    params.values.all?
  end

  def check_remote_api
    @check_item.save!
    query_proxy_api
    if @result
      @check_item.dwp_result = @response['benefit_checker_status']
      @check_item.dwp_api_token = @response['confirmation_ref']
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
    @check_item.error_message = message
    @check_item.update!(dwp_result: result)
    LogStuff.log 'Benefit check', message
  end
end
