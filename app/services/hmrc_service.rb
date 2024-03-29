class HmrcService
  attr_reader :hmrc_check, :form

  def initialize(application, form)
    @application = application
    @form = form
  end

  def call
    api_call
  rescue HwfHmrcApiError => e
    process_standard_error(e)
    false
  rescue Net::ReadTimeout
    process_timeout_error
    false
  end

  # rubocop:disable Metrics/AbcSize
  def load_form_default_data_range
    last_month = load_date_based_on_type - 1.month
    @form.from_date_day = last_month.beginning_of_month.day
    @form.from_date_month = last_month.month
    @form.from_date_year = last_month.year
    @form.to_date_day = last_month.end_of_month.day
    @form.to_date_month = last_month.month
    @form.to_date_year = last_month.year
    @form
  end
  # rubocop:enable Metrics/AbcSize

  def load_date_based_on_type
    return @application.detail.date_fee_paid.to_date if @application.detail.refund
    @application.detail.date_received.to_date
  end

  def update_additional_income(hmrc_params)
    @form.additional_income = hmrc_params['additional_income']
    @form.additional_income_amount = additional_income_amount(hmrc_params)
    @form.save
  end

  private

  def api_call
    @hmrc_service = HmrcApiService.new(@application, @form.user_id)
    @hmrc_service.match_user
    @hmrc_service.income(@form.from_date, @form.to_date)
    @hmrc_check = @hmrc_service.hmrc_check
  end

  def process_standard_error(error)
    store_error(error)
    message = error.message
    if message.include?('MESSAGE_THROTTLED_OUT')
      message = "HMRC checking is currently unavailable please try again later. (429)"
    end
    @form.errors.add(:request, message)
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

end
