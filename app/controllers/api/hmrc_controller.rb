module Api
  class HmrcController < ApplicationController
    require 'oauth2'

    protect_from_forgery with: :null_session, only: proc { |c| c.request.format.json? }

    skip_before_action :authenticate_user!
    skip_after_action :verify_authorized

    before_action :load_credentials

# access_token  "bf9c01f5d44eb67f3dd3eb172fbf16bb"
# scope "read:individuals-matching-hmcts-c2 read:individuals-income-hmcts-c2 assigned read:individuals-employments-hmcts-c2 read:individuals-benefits-and-credits-hmcts-c2"
# expires_in  14400
# token_type  "bearer"

    def get_token
      party = HTTParty.post('https://test-api.service.hmrc.gov.uk/oauth/token',
        headers: {"content-type"=> "application/x-www-form-urlencoded"},
        body: { client_secret: @client_secret, client_id: @client_id, grant_type: 'client_credentials'})

      render json: party
    end

# curl -d '{"serviceNames": ["national-insurance","self-assessment","mtd-income-tax","customs-services","goods-vehicle-movements","mtd-vat", "ics-safety-and-security", "common-transit-convention-traders"]}' -H "Content-Type: application/json" -H "Accept:application/vnd.hmrc.1.0+json" -H "Authorization:Bearer bf9c01f5d44eb67f3dd3eb172fbf16bb " -X POST https://test-api.service.hmrc.gov.uk/create-test-user/individuals
    def create_user
      party = HTTParty.post('https://test-api.service.hmrc.gov.uk/create-test-user/individuals',
        headers: {"Content-Type"=> "application/json", "Accept" => "application/vnd.hmrc.1.0+json", "Authorization" => "Bearer bf9c01f5d44eb67f3dd3eb172fbf16bb" },
        body: {serviceNames: ["national-insurance","self-assessment","mtd-income-tax","customs-services","goods-vehicle-movements","mtd-vat", "ics-safety-and-security", "common-transit-convention-traders"]}.to_json
      )

      render json: party
    end

# {"userId":"339101497865","password":"tqcxxarobr0h","userFullName":"Kay Draper","emailAddress":"kay.draper@example.com","individualDetails":{"firstName":"Kay","lastName":"Draper","dateOfBirth":"1951-06-27","address":{"line1":"28 Battersea Bridge Road","line2":"Poole","postcode":"TS13 1PA"}},"saUtr":"9652728541","nino":"OL737882D","mtdItId":"XPIT00098279342","vrn":"545993397","vatRegistrationDate":"2020-02-17","eoriNumber":"GB374720000904","groupIdentifier":"367426073069"}%
    def match_user
      party = HTTParty.post('https://test-api.service.hmrc.gov.uk/individuals/matching',
        headers: {"Content-Type": "application/json", "correlationId"=> "58072660-1df9-4deb-b4ca-cd2d7f96e480", "Accept" => "application/vnd.hmrc.2.0+json", "Authorization" => "Bearer bf9c01f5d44eb67f3dd3eb172fbf16bb" },
        body: {"firstName": "Kay","lastName": "Draper","nino": "OL737882D","dateOfBirth": "1951-06-27"}.to_json,
        debug_output: STDOUT
      )

      render json: party
    end

# individual
# name  "GET"
# href  "/individuals/matching/9ff6bbe9-fa82-4765-b8ec-fe46fc443107"
# title "Get a matched individual’s information"
# self
# href  "/individuals/matching/"


    def matching_links
      party = HTTParty.get("https://test-api.service.hmrc.gov.uk/individuals/matching/9ff6bbe9-fa82-4765-b8ec-fe46fc443107",
       :headers => {
              "Content-Type": "application/json",
              "Accept" => "application/vnd.hmrc.2.0+json",
              "Authorization" => "Bearer bf9c01f5d44eb67f3dd3eb172fbf16bb",
              "correlationId" => "58072660-1df9-4deb-b4ca-cd2d7f96e480"
      })

      render json: party
    end

# individual
# firstName "Kay"
# lastName  "Draper"
# nino  "OL737882D"
# dateOfBirth "1951-06-27"
# _links
# benefits-and-credits
# name  "GET"
# href  "/individuals/benefits-and-credits/?matchId=9ff6bbe9-fa82-4765-b8ec-fe46fc443107"
# title "Get the individual's benefits and credits data"
# income
# name  "GET"
# href  "/individuals/income/?matchId=9ff6bbe9-fa82-4765-b8ec-fe46fc443107"
# title "Get the individual's income data"
# self
# href  "/individuals/matching/9ff6bbe9-fa82-4765-b8ec-fe46fc443107"
# employments
# name  "GET"
# href  "/individuals/employments/?matchId=9ff6bbe9-fa82-4765-b8ec-fe46fc443107"
# title "Get the individual's employment data"




    def income
      party = HTTParty.get("https://test-api.service.hmrc.gov.uk//individuals/income/?matchId=9ff6bbe9-fa82-4765-b8ec-fe46fc443107",
       :headers => {
              "Content-Type": "application/json",
              "Accept" => "application/vnd.hmrc.2.0+json",
              "Authorization" => "Bearer bf9c01f5d44eb67f3dd3eb172fbf16bb",
              "correlationId" => "58072660-1df9-4deb-b4ca-cd2d7f96e480"}

      )

      render json: party
    end



    def test
      party =   HTTParty.get("https://test-api.service.hmrc.gov.uk/hello/application", :headers => {
          "Accept" => "application/vnd.hmrc.1.0+json",
          "Authorization" => "Bearer b7b28f708f670c1d6bee61130253ccf7"
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
