module Api
  class HmrcController < ApplicationController
    require 'oauth2'

    protect_from_forgery with: :null_session, only: proc { |c| c.request.format.json? }

    skip_before_action :authenticate_user!
    skip_after_action :verify_authorized

    before_action :load_credentials

    def get_token
      party = HTTParty.post('https://test-api.service.hmrc.gov.uk/oauth/token',
        headers: {"content-type"=> "application/x-www-form-urlencoded"},
        body: { client_secret: @client_secret, client_id: @client_id, grant_type: 'client_credentials'})
      
      render json: party
    end

    def callback
      binding.pry
      render text: 'ok'
    end

    private
    def load_credentials
      secret = ENV['HMRC_SECRET'] 
      @client_secret = ttp_code + secret
      @client_id = ENV['HMRC_CLIENT_ID'] 
    end

    def authenticate
      authenticate_or_request_with_http_token do |token, _options|
        token == Settings.submission.token
      end
    end

    def ttp_code
      ttp_secret = ENV['HMRC_TTP_SECRET']
      b32_code = ROTP::Base32.encode(ttp_secret)
      totp = ROTP::TOTP.new(b32_code, digits: 8)
      totp.now  
    end
  end
end
