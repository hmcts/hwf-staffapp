module Api
  class HmrcController < ApplicationController
    require 'oauth2'

    protect_from_forgery with: :null_session, only: proc { |c| c.request.format.json? }

    skip_before_action :authenticate_user!
    skip_after_action :verify_authorized

    before_action :load_credentials

    def test
      party = HTTParty.get('https://test-api.service.hmrc.gov.uk/hello/user',
        headers: {"Accept"=> "application/vnd.hmrc.1.0+json", "Authorization" => "Bearer 109a0a8c2a452c73a7bdf6d40369da09"},
        body: {})

      render json: party

    end

    def get_token
      party = HTTParty.post('https://test-api.service.hmrc.gov.uk/oauth/token',
        headers: {"content-type"=> "application/x-www-form-urlencoded"},
        body: { client_secret: @client_secret, client_id: @client_id, grant_type: 'client_credentials'})

      render json: party
    end

    def hello
      party =   HTTParty.get("https://test-api.service.hmrc.gov.uk/hello/application", :headers => {
          "Accept" => "application/vnd.hmrc.1.0+json",
          "Authorization" => "Bearer f2c649d4c8951d30e7013e032b8b6a8f"
})

      render json: party
    end

    def callback
      render text: 'ok'
    end

    private
    def load_credentials
      secret = ENV['HMRC_SECRET']
      @client_secret = ttp_code + secret
      puts @client_secret
      @client_id = ENV['HMRC_CLIENT_ID']
    end

    def authenticate
      authenticate_or_request_with_http_token do |token, _options|
        token == Settings.submission.token
      end
    end

    def ttp_code
      ttp_secret = ENV['HMRC_TTP_SECRET']
      totp = ROTP::TOTP.new(ttp_secret, digits: 8, digest: 'sha512')
      totp.now
    end
  end
end
