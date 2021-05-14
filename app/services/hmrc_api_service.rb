class HmrcApiService
  def initialize(application)
    @application = application
    hmrc_api_innitialize
  end

  def income
  end

  def address
  end

  def employment
  end

  def tax_credit
  end

  def hmrc_api_innitialize
    @hwf = HwfHmrcApi.new(hmrc_api_attributes)
    @hwf.match_user(user_params)
  end

  private

  # TODO whitelist credentials from logs
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

  def applicant
  end

  # load / store access_token and expires_at values
  def hmrc_api_credentials
  end
end