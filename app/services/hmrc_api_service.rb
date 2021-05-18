class HmrcApiService

  def initialize(application)
    @application = application
    hmrc_api_innitialize
  end

  # from_date format: YYYY-MM-DD
  # to_date format: YYYY-MM-DD
  def income(from, to)
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
    data = @hwf.working_tax_credits(from, to)
    store_response_data('tax_credit', data)
  end

  def hmrc_api_innitialize
    @hwf = HwfHmrcApi.new(hmrc_api_attributes)
    @hwf.match_user(user_params)
  end

  def hmrc_check
    @hmrc_check ||= HmrcCheck.new
  end

  private

  def store_response_data(type, data)
    hmrc_check.send("#{type}=", data)
    hmrc_check.save
  end

  # TODO: whitelist credentials from logs
  def hmrc_api_attributes
    {
      hmrc_secret: ENV['HMRC_SECRET'],
      totp_secret: ENV['HMRC_TTP_SECRET'],
      client_id: ENV['HMRC_CLIENT_ID']
    }
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

  def applicant; end

  # load / store access_token and expires_at values
  def hmrc_api_credentials; end
end
