class BenefitCheckRunner < BaseBenefitCheckRunner
  def initialize(application)
    @application = application
    @date_data = @application.detail
    @applicant = @application.applicant
  end

  def can_run?
    applicant.last_name.present? &&
      applicant.date_of_birth.present? &&
      applicant.ni_number.present? &&
      benefit_check_date.present?
  end

  def run
    if allow_benefit_check_call?
      log_benefit_call
      BenefitCheckService.new(benefit_check)
      @application.update(application_type: 'benefit', outcome: benefit_check.outcome, amount_to_pay: amount_to_pay)
    elsif load_previous_check?
      @application.update(outcome: previous_check.outcome)
    elsif @application.outcome.blank?
      @application.update(outcome: 'none')
    end
  end

  def can_override?
    benefit_check.blank? || benefit_check.dwp_result.blank? || overridable_result?
  end

  private

  def applicant
    @application.applicant
  end

  def should_run?
    previous_check.nil? || !same_as_before? || was_error?
  end

  def was_error?
    ['Yes', 'No'].exclude?(previous_check.dwp_result)
  end

  def same_as_before?
    applicant_same? && (previous_check.date_to_check == benefit_check_date)
  end

  def applicant_same?
    [:last_name, :date_of_birth, :ni_number].all? do |field|
      previous_check.send(field) == applicant.send(field)
    end
  end

  def previous_check
    @previous_check ||= @application.last_benefit_check
  end

  def benefit_check
    @benefit_check ||= BenefitCheck.create(
      applicationable: @application,
      last_name: applicant.last_name,
      date_of_birth: applicant.date_of_birth,
      ni_number: applicant.ni_number,
      date_to_check: benefit_check_date,
      our_api_token: generate_api_token,
      parameter_hash: build_hash,
      user_id: @application.user_id
    )
  end

  def generate_api_token
    short_name = @application.user.name.delete(' ').downcase.truncate(27)
    "#{short_name}@#{@application.created_at.strftime('%y%m%d%H%M%S')}.#{@application.id}"
  end

  def overridable_result?
    result = benefit_check.dwp_result.downcase
    ['no', 'server unavailable', 'undetermined', 'unspecified error'].include?(result)
  end

  def load_previous_check?
    @application.outcome.blank? && previous_check.present? && !previous_check.outcome.nil?
  end

  def amount_to_pay
    benefit_check.outcome == 'full' ? nil : @application.amount_to_pay
  end

  def log_benefit_call
    tc = ApplicationInsights::TelemetryClient.new ENV.fetch('AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY', nil)
    tc.track_event("#{@application.id} Paper BenefitCheck call #{Time.zone.today}")
    tc.flush
  end

  def checks_allowed?
    DwpWarning.order(id: :desc).first&.check_state != DwpWarning::STATES[:offline]
  end

  def allow_benefit_check_call?
    can_run? && should_run? && checks_allowed?
  end
end
