class HmrcApiService
  include HmrcPersonLoadable
  include HmrcTokenable

  def initialize(application, user_id, check_type = 'applicant')
    @application = application
    @user_id = user_id
    @check_type = check_type
    hmrc_check_initialize
  end

  def match_user
    hmrc_api_innitialize
  end

  # from_date format: YYYY-MM-DD
  # to_date format: YYYY-MM-DD
  def income(from, to)
    store_request(from, to)
    paye(from, to)
    tax_credit(from, to)
  end

  # from_date format: YYYY-MM-DD
  # to_date format: YYYY-MM-DD
  def paye(from, to)
    id = hmrc_call({ from: from, to: to }, :paye)
    data = @hwf.paye(from, to, id)
    store_response_data('income', data)
  end

  # from_date format: YYYY-MM-DD
  # to_date format: YYYY-MM-DD
  def address(from, to)
    id = hmrc_call({ from: from, to: to }, :address)
    data = @hwf.addresses(from, to, id)
    store_response_data('address', data)
  end

  # from_date format: YYYY-MM-DD
  # to_date format: YYYY-MM-DD
  def employment(from, to)
    id = hmrc_call({ from: from, to: to }, :employment)
    data = @hwf.employments(from, to, id)
    store_response_data('employment', data)
  end

  # from_date format: YYYY-MM-DD
  # to_date format: YYYY-MM-DD
  def tax_credit(from, to)
    child = child_tax_credit(from, to)
    work = work_tax_credit(from, to)
    @hmrc_check.tax_credit = { child: child, work: work }
    @hmrc_check.save
  end

  def child_tax_credit(from, to)
    id = hmrc_call({ from: from, to: to }, :child_tax_credits)
    @hwf.child_tax_credits(from, to, id).try(:[], 0).try(:[], 'awards')
  end

  def work_tax_credit(from, to)
    id = hmrc_call({ from: from, to: to }, :working_tax_credits)
    @hwf.working_tax_credits(from, to, id).try(:[], 0).try(:[], 'awards')
  end

  def hmrc_api_innitialize
    @hwf = HwfHmrcApi.new(hmrc_api_attributes)
    id = hmrc_call(user_params, :match_user)
    @hwf.match_user(user_params, id)
    update_hmrc_token(@hwf.authentication.access_token, @hwf.authentication.expires_in)
  end

  def hmrc_check
    @hmrc_check ||= HmrcCheck.new(evidence_check: @application.evidence_check, check_type: @check_type)
  end

  private

  def store_response_data(type, data)
    @hmrc_check.send(:"#{type}=", data.send(:[], type))
    @hmrc_check.save
    raise_error_if_no_data(type, data)
  end

  # TODO: whitelist credentials from logs
  def hmrc_api_attributes
    {
      hmrc_secret: ENV.fetch('HMRC_SECRET', nil),
      totp_secret: ENV.fetch('HMRC_TTP_SECRET', nil),
      client_id: ENV.fetch('HMRC_CLIENT_ID', nil)
    }.merge(hmrc_api_credentials)
  end

  def hmrc_check_initialize
    hmrc_check
    @hmrc_check.ni_number = person_ni_number
    @hmrc_check.date_of_birth = person_dob&.to_fs(:db)
    @hmrc_check.user_id = @user_id
    @hmrc_check.save
  end

  def store_request(from, to)
    @hmrc_check.request_params = { date_range: { from: from, to: to } }
    @hmrc_check.save
  end

  def uuid
    SecureRandom.uuid
  end

  def hmrc_call(call_params, endpoint)
    call = HmrcCall.create(call_params: call_params, endpoint_name: endpoint, hmrc_check: @hmrc_check)
    call.id
  end

  def raise_error_if_no_data(type, data)
    # don't fail if married
    return if married?
    raise HwfHmrcApiError, "NO RESULT - No record found" if data.send(:[], type).blank?
  end

  def married?
    @application.applicant.married
  end

end
