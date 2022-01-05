class HmrcApiService

  def initialize(application, user_id)
    @application = application
    @user_id = user_id
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

  def paye(from, to)
    data = @hwf.paye(from, to)
    store_response_data('income', data)
  end

  # from_date format: YYYY-MM-DD
  # to_date format: YYYY-MM-DD
  def address(from, to)
    data = @hwf.addresses(from, to)
    store_response_data('address', data)
  end

  # from_date format: YYYY-MM-DD
  # to_date format: YYYY-MM-DD
  def employment(from, to)
    data = @hwf.employments(from, to)
    store_response_data('employment', data)
  end

  # from_date format: YYYY-MM-DD
  # to_date format: YYYY-MM-DD
  def tax_credit(from, to)
    child = @hwf.child_tax_credits(from, to).try(:[], 0).try(:[], 'awards')
    work = @hwf.working_tax_credits(from, to).try(:[], 0).try(:[], 'awards')
    @hmrc_check.tax_credit = { child: child, work: work }
    @hmrc_check.save
  end

  def hmrc_api_innitialize
    @hwf = HwfHmrcApi.new(hmrc_api_attributes)
    @hwf.match_user(user_params)
    update_hmrc_token(@hwf.authentication.access_token, @hwf.authentication.expires_in)
  end

  def hmrc_check
    @hmrc_check ||= HmrcCheck.new(evidence_check: @application.evidence_check)
  end

  private

  def store_response_data(type, data)
    @hmrc_check.send("#{type}=", data.send("[]", type))
    @hmrc_check.save
    raise HwfHmrcApiError, "NO RESULT - No record found" if data.send("[]", type).blank?
  end

  # TODO: whitelist credentials from logs
  def hmrc_api_attributes
    {
      hmrc_secret: ENV['HMRC_SECRET'],
      totp_secret: ENV['HMRC_TTP_SECRET'],
      client_id: ENV['HMRC_CLIENT_ID']
    }.merge(hmrc_api_credentials)
  end

  def user_params
    applicant = @application.applicant
    {
      first_name: applicant.first_name,
      last_name: applicant.last_name,
      nino: applicant.ni_number,
      dob: applicant.date_of_birth.strftime('%Y-%m-%d')
    }
  end

  # load / store access_token and expires_in values
  def hmrc_api_credentials
    hrmc_token = HmrcToken.last
    return {} if hrmc_token.nil? || hrmc_token.expired?
    { access_token: hrmc_token.access_token, expires_in: hrmc_token.expires_in }
  end

  def update_hmrc_token(access_token, expires_in)
    hmrc_token = HmrcToken.last || HmrcToken.new
    return if hmrc_token.access_token == access_token

    hmrc_token.access_token = access_token
    hmrc_token.expires_in = expires_in
    hmrc_token.save
  end

  def hmrc_check_initialize
    hmrc_check
    @hmrc_check.ni_number = @application.applicant.ni_number
    @hmrc_check.date_of_birth = @application.applicant.date_of_birth
    @hmrc_check.user_id = @user_id
    @hmrc_check.save
  end

  def store_request(from, to)
    @hmrc_check.request_params = { date_range: { from: from, to: to } }
    @hmrc_check.save
  end

end
