class OnlineBenefitCheckRunner
  def initialize(online_application)
    @online_application = online_application
  end

  def can_run?
    @online_application.last_name.present? &&
      @online_application.date_of_birth.present? &&
      @online_application.ni_number.present? &&
      benefit_check_date.present?
  end

  def run
    if can_run? && benefit_check_date_valid?
      BenefitCheckService.new(benefit_check)
    end
  end

  def benefit_check_date_valid?
    benefit_check_date > Time.zone.now - 3.months
  end

  private

  def benefit_check
    @benefit_check ||= OnlineBenefitCheck.create(
      online_application: @online_application,
      last_name: @online_application.last_name,
      date_of_birth: @online_application.date_of_birth,
      ni_number: @online_application.ni_number,
      date_to_check: benefit_check_date,
      our_api_token: generate_api_token,
      parameter_hash: build_hash
    )
  end

  def benefit_check_date
    if @online_application.date_fee_paid.present?
      @online_application.date_fee_paid
    elsif @online_application.date_received.present?
      @online_application.date_received
    end
  end

  def build_hash
    Base64.encode64 [@online_application.last_name,
                     @online_application.date_of_birth,
                     @online_application.ni_number,
                     benefit_check_date].to_s
  end

  def generate_api_token
    short_name = @online_application.last_name.delete(' ').downcase.truncate(27)
    "#{short_name}@#{@online_application.created_at.strftime('%y%m%d%H%M%S')}.#{@online_application.id}"
  end

end
