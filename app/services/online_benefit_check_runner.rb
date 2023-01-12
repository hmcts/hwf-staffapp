class OnlineBenefitCheckRunner < BaseBenefitCheckRunner
  def initialize(online_application)
    @online_application = online_application
    @date_data = online_application
    @applicant = online_application
  end

  def run
    if can_run? && benefit_check_date_valid?
      BenefitCheckService.new(benefit_check)
    end
  end

  def benefit_check_date_valid?
    true
    # based on "paper" application logic online applications dont't take
    # notice of benefit_check data validity
  end

  private

  def benefit_check
    @benefit_check ||= BenefitCheck.create(
      applicationable: @online_application,
      last_name: @online_application.last_name,
      date_of_birth: @online_application.date_of_birth,
      ni_number: @online_application.ni_number,
      date_to_check: benefit_check_date,
      our_api_token: generate_api_token,
      parameter_hash: build_hash,
      user_id: @online_application.user_id
    )
  end

  def generate_api_token
    short_name = @online_application.last_name.delete(' ').downcase.truncate(27)
    "#{short_name}@#{@online_application.created_at.strftime('%y%m%d%H%M%S')}.#{@online_application.id}"
  end

end
