class BenefitCheckService
  attr_accessor :result, :message, :response

  def initialize(data_to_check)
    @result = false
    @check_item = data_to_check
    begin
      validate_inputs
      check_remote_api
    rescue
      @check_item.benefits_valid = @result
      log_error I18n.t('error_messages.benefit_checker.undetermined'), 'Undetermined'
    end
  end

  private

  def validate_inputs
    params.values.all?
  end

  def check_remote_api
    @check_item.save!
    process_proxy_api_call
    if @result
      @check_item.dwp_result = @response['benefit_checker_status']
      @check_item.dwp_api_token = @response['confirmation_ref']
    end
    @check_item.benefits_valid = (@check_item.dwp_result == 'Yes' ? true : false)
    @check_item.save!
  end

  def process_proxy_api_call
    query_proxy_api
  rescue RestClient::BadRequest => e
    log_error JSON.parse(e.response)['error'], 'BadRequest'
  rescue Exceptions::UndeterminedDwpCheck
    log_error I18n.t('error_messages.benefit_checker.undetermined'), 'Undetermined'
  rescue Errno::ECONNREFUSED
    log_error I18n.t('error_messages.benefit_checker.unavailable'), 'Server unavailable'
  rescue => e
    log_error(e.message, 'Unspecified error')
  end

  def query_proxy_api
    @response = JSON.parse(RestClient.post("#{ENV['DWP_API_PROXY']}/api/benefit_checks", params))
    fail Exceptions::UndeterminedDwpCheck if @response['benefit_checker_status'] == 'Undetermined'
    @result = true
  end

  def params
    {
      id: @check_item.our_api_token,
      ni_number: @check_item.ni_number,
      surname: @check_item.last_name.upcase,
      birth_date: @check_item.date_of_birth.strftime('%Y%m%d'),
      entitlement_check_date: process_check_date
    }
  end

  def process_check_date
    check_date = @check_item.date_to_check ? @check_item.date_to_check : Time.zone.today
    check_date.strftime('%Y%m%d')
  end

  def log_error(message, result)
    @check_item.error_message = message
    @check_item.update!(dwp_result: result)
    LogStuff.log @check_item.class.name.titleize.humanize, message
  end
end
