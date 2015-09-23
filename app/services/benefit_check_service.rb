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
end
