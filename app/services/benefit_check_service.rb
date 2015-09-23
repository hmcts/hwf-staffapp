class BenefitCheckService

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
    set_params.values.all?
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
      birth_date: @check_item.date_of_birth.strftime('%Y%m%d'),
      entitlement_check_date: process_check_date
    }
  end

  def log_error(message, result)
    @check_item.error_message = message
    @check_item.update!(dwp_result: result)
    LogStuff.log 'Benefit check', message
  end

  def process_check_date
    check_date = @check_item.date_to_check ? @check_item.date_to_check : Time.zone.today
    check_date.strftime('%Y%m%d')
  end
end
