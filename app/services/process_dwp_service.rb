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
end
