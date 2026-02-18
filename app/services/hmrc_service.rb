class HmrcService
  attr_reader :hmrc_check, :form

  def initialize(application, form)
    @application = application
    @form = form
  end

  def call
    applicant_call = api_call
    partner_call = api_call('partner') if applicant_married? && partner_valid_for_check?
    applicant_call || partner_call
  rescue HwfHmrcApiError => e
    process_standard_error(e)
    false
  rescue Net::ReadTimeout
    process_timeout_error
    false
  end

  # rubocop:disable Metrics/AbcSize
  def load_form_default_data_range
    from_date = range_start_based_on_income_period
    to_date = load_date_based_on_type - 1.month

    @form.from_date_day = from_date.beginning_of_month.day
    @form.from_date_month = from_date.month
    @form.from_date_year = from_date.year
    @form.to_date_day = to_date.end_of_month.day
    @form.to_date_month = to_date.month
    @form.to_date_year = to_date.year
    @form
  end
  # rubocop:enable Metrics/AbcSize

  def range_start_based_on_income_period
    if @application.income_period_three_months_average?
      load_date_based_on_type - 3.months
    else
      load_date_based_on_type - 1.month
    end
  end

  def load_date_based_on_type
    return @application.detail.date_fee_paid.to_date if @application.detail.refund
    @application.detail.date_received.to_date
  end

  def update_additional_income(hmrc_params)
    @form.additional_income = hmrc_params['additional_income']
    @form.additional_income_amount = additional_income_amount(hmrc_params)
    @form.save
  end

  def display_partner_data_missing_for_check?
    applicant_married? && !partner_valid_for_check?
  end

  private

  def api_call(check_type = 'applicant')
    @hmrc_service = HmrcApiService.new(@application, @form.user_id, check_type)
    @hmrc_service.match_user
    @hmrc_service.income(@form.from_date, @form.to_date)
    @hmrc_check = @hmrc_service.hmrc_check
  end

  def process_standard_error(error)
    store_error(error)
    message = error.message
    if message.include?('MESSAGE_THROTTLED_OUT')
      message = "HMRC checking is currently unavailable please try again later. (429)"
    elsif partners_data_not_found(message)
      message = "HMRC can’t receive data from both applicant and partner"
    end
    @form.errors.add(:request, message)
  end

  def partners_data_not_found(message)
    message.include?('MATCHING_FAILED') && applicant_married? && partner_valid_for_check?
  end

  def process_timeout_error
    store_error('Net::ReadTimeout - Timeout error')
    message = "HMRC income checking failed. Submit this form again for HMRC income checking"
    @form.errors.add(:timout, message)
  end

  def additional_income_amount(hmrc_params)
    if hmrc_params['additional_income'] == 'false'
      0
    else
      hmrc_params['additional_income_amount']
    end
  end

  def store_error(error)
    @hmrc_check = @hmrc_service.hmrc_check
    return unless @hmrc_check
    @hmrc_check.update(error_response: error.to_s)
  end

  def applicant_married?
    @application.applicant.married?
  end

  def partner_valid_for_check?
    @application.applicant.partner_ni_number.present? &&
      @application.applicant.partner_first_name.present? &&
      @application.applicant.partner_last_name.present? &&
      @application.applicant.partner_date_of_birth.present?
  end

end
