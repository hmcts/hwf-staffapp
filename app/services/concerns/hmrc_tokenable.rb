module HmrcTokenable
  extend ActiveSupport::Concern

  # load / store access_token and expires_in values
  def hmrc_api_credentials
    hrmc_token = HmrcToken.last
    return {} if hrmc_token.nil? || hrmc_token.expired?
    { access_token: hrmc_token.access_token, expires_in: hrmc_token.expires_in }
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    HmrcToken.last.destroy
    {}
  end

  def update_hmrc_token(access_token, expires_in)
    @hmrc_token = HmrcToken.last || HmrcToken.new
    return if @hmrc_token.access_token == access_token
    store_hmrc_token(access_token, expires_in)
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    HmrcToken.last.destroy
    store_hmrc_token(access_token, expires_in)
  end

  def store_hmrc_token(access_token, expires_in)
    @hmrc_token.access_token = access_token
    @hmrc_token.expires_in = expires_in
    @hmrc_token.save
  end

end
