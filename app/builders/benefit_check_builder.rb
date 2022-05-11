class BenefitCheckBuilder

  def initialize(application)
    @application = application
  end

  def build
    benefit_check = copy_from_online_check
    if benefit_check.save
      online_benefit_check.destroy
      @application.update(outcome: benefit_check.outcome, application_type: 'benefit')
    end
  end

  private

  def copy_from_online_check
    attributes = {
      application_id: @application.id,
      user_id: @application.user.id
    }.merge(online_benefit_check_attributes)

    BenefitCheck.new(attributes)
  end

  # rubocop:disable Metrics/AbcSize
  def online_benefit_check_attributes
    { last_name: online_benefit_check.last_name,
      date_of_birth: online_benefit_check.date_of_birth,
      ni_number: online_benefit_check.ni_number,
      date_to_check: online_benefit_check.date_to_check,
      parameter_hash: online_benefit_check.parameter_hash,
      benefits_valid: online_benefit_check.benefits_valid,
      dwp_result: online_benefit_check.dwp_result,
      error_message: online_benefit_check.error_message,
      dwp_api_token: online_benefit_check.dwp_api_token,
      our_api_token: online_benefit_check.our_api_token }
  end
  # rubocop:enable Metrics/AbcSize

  def online_benefit_check
    @online_benefit_check ||= @application.online_application.last_benefit_check
  end
end
