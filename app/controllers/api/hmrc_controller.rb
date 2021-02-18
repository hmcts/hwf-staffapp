module Api
  class HmrcController < ApplicationController
    require 'oauth2'

    protect_from_forgery with: :null_session, only: proc { |c| c.request.format.json? }

    skip_before_action :authenticate_user!
    skip_after_action :verify_authorized

    before_action :load_credentials

    # works
    def get_token
      party = HTTParty.post('https://test-api.service.hmrc.gov.uk/oauth/token',
        headers: {"content-type"=> "application/x-www-form-urlencoded"},
        body: { client_secret: @client_secret, client_id: @client_id, grant_type: 'client_credentials'})

      render json: party
    end

    # works
    def create_user
      party = HTTParty.post('https://test-api.service.hmrc.gov.uk/create-test-user/individuals',
        headers: { "Content-Type"=> "application/json",
          "Accept" => "application/vnd.hmrc.1.0+json",
          "Authorization" => access_token },
        body: {serviceNames: ["national-insurance","self-assessment","mtd-income-tax","customs-services","goods-vehicle-movements","mtd-vat", "ics-safety-and-security", "common-transit-convention-traders"]}.to_json
      )

      render json: party
    end

    # works
    # api/match_user
    def match_user
      party = HTTParty.post('https://test-api.service.hmrc.gov.uk/individuals/matching',
        headers: { "Content-Type": "application/json",
         "correlationId" => UUID.new.generate,
         "Accept" => "application/vnd.hmrc.2.0+json",
         "Authorization" => access_token },
        body: {"firstName": "Kay","lastName": "Draper","nino": "OL737882D","dateOfBirth": "1951-06-27"}.to_json,
        debug_output: STDOUT
      )

      render json: party
    end

    # works
    # api/links
    def matching_links
      party = HTTParty.get("https://test-api.service.hmrc.gov.uk/individuals/matching/#{match_id}",
        headers: {
          "Content-Type": "application/json",
          "Accept" => "application/vnd.hmrc.2.0+json",
          "Authorization" => access_token,
          "correlationId" => UUID.new.generate
        })

      render json: party
    end

    # works
    # api/employments
    def employments
      party = HTTParty.get("https://test-api.service.hmrc.gov.uk/individuals/employments",
        headers: {
          "Content-Type": "application/json",
          "Accept" => "application/vnd.hmrc.2.0+json",
          "Authorization" => access_token,
          "correlationId" => UUID.new.generate
        },
        query: {
          matchId: match_id
        },
        debug_output: STDOUT
      )

      render json: party
    end

    # /api/employment/paye
    # INTERNAL_SERVER_ERROR 18.2
    def employment_paye
      # individuals/employments/paye?matchId=27e51b22-9e56-4767-a952-1ff4173427f7{&fromDate,toDate}
      party = HTTParty.get("https://test-api.service.hmrc.gov.uk/individuals/employments/paye",
        headers: {
          "Content-Type": "application/json",
          "Accept" => "application/vnd.hmrc.2.0+json",
          "Authorization" => access_token,
          "correlationId" => UUID.new.generate
        },
        query: {
          matchId: match_id,
          fromDate: '2018-01-01',
          toDate: '2020-01-01'
        },
        debug_output: STDOUT
      )

      render json: party
    end

    # api/incomes
    # works
    def incomes
      party = HTTParty.get("https://test-api.service.hmrc.gov.uk/individuals/income/",
        headers: {
              "Content-Type": "application/json",
              "Accept" => "application/vnd.hmrc.2.0+json",
              "Authorization" => access_token,
              "correlationId" => UUID.new.generate},
        query: {
          matchId: match_id,
        },
        debug_output: STDOUT
      )

      render json: party
    end

    # INTERNAL_SERVER_ERROR
    # api/incomes/paye
    def income_paye
      # /individuals/income/paye?matchId=27e51b22-9e56-4767-a952-1ff4173427f7{&fromDate,toDate}"
      party = HTTParty.get("https://test-api.service.hmrc.gov.uk/individuals/income/paye",
        headers: {
              "Content-Type": "application/json",
              "Accept" => "application/vnd.hmrc.2.0+json",
              "Authorization" => access_token,
              "correlationId" => UUID.new.generate},
        query: {
          matchId: match_id,
          fromDate: '2018-01-01',
          toDate: '2020-01-01'
        },
        debug_output: STDOUT
      )

      render json: party
    end

    # INTERNAL_SERVER_ERROR
    # api/incomes/sa
    def income_sa
      # /individuals/income/sa?matchId=27e51b22-9e56-4767-a952-1ff4173427f7{&fromTaxYear,toTaxYear}
      party = HTTParty.get("https://test-api.service.hmrc.gov.uk/individuals/income/sa",
        headers: {
              "Content-Type": "application/json",
              "Accept": "application/vnd.hmrc.2.0+json",
              "Authorization": access_token,
              "correlationId": UUID.new.generate},
        query: {
          matchId: match_id,
          fromTaxYear: '2018-19'
        },
        debug_output: STDOUT
      )

      render json: party
    end

    # works
    # api/benefits_and_credits
    def benefits_and_credits
      # /individuals/benefits-and-credits/?matchId=27e51b22-9e56-4767-a952-1ff4173427f7
      party = HTTParty.get("https://test-api.service.hmrc.gov.uk/individuals/benefits-and-credits/",
        headers: {
              "Content-Type": "application/json",
              "Accept": "application/vnd.hmrc.1.0+json",
              "Authorization": access_token,
              "correlationId": UUID.new.generate},
        query: {
          matchId: match_id
        },
        debug_output: STDOUT
      )

      render json: party
    end

    # INTERNAL_SERVER_ERROR
    # api/benefits_and_credits/work
    def benefits_work
      # /individuals/benefits-and-credits/working-tax-credit?matchId=27e51b22-9e56-4767-a952-1ff4173427f7{&fromDate,toDate
      party = HTTParty.get("https://test-api.service.hmrc.gov.uk/individuals/benefits-and-credits/working-tax-credit",
        headers: {
              "Content-Type": "application/json",
              "Accept": "application/vnd.hmrc.1.0+json",
              "Authorization": access_token,
              "correlationId": UUID.new.generate},
        query: {
          matchId: match_id,
          fromDate: '2018-01-01',
          toDate: '2020-01-01'
        },
        debug_output: STDOUT
      )

      render json: party
    end

    # INTERNAL_SERVER_ERROR
    # api/benefits_and_credits/child
    def benefits_child
      # /individuals/benefits-and-credits/child-tax-credit?matchId=27e51b22-9e56-4767-a952-1ff4173427f7{&fromDate,toDate}
      party = HTTParty.get("https://test-api.service.hmrc.gov.uk/individuals/benefits-and-credits/child-tax-credit",
        headers: {
              "Content-Type": "application/json",
              "Accept": "application/vnd.hmrc.1.0+json",
              "Authorization": access_token,
              "correlationId": UUID.new.generate},
        query: {
          matchId: match_id,
          fromDate: '2018-01-01',
          toDate: '2020-01-01'
        },
        debug_output: STDOUT
      )

      render json: party
    end


    def create_paye
      party = HTTParty.post('https://test-api.service.hmrc.gov.uk/individuals/integration-framework-test-support/individuals/income/paye/nino/OL737882D',
        headers: { "Content-Type": "application/json",
         "Accept" => "application/vnd.hmrc.1.0+json",
         "Authorization" => access_token },
        body: paye_hash,
        debug_output: STDOUT)

        render json: party
    end

    def test
      party = HTTParty.get("https://test-api.service.hmrc.gov.uk/hello/application", :headers => {
          "Accept" => "application/vnd.hmrc.1.0+json",
          "Authorization" => access_token
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

    def access_token
      'Bearer ada667c62b5c5a15c3c99f725395c04c'
    end

    def match_id
      'cf50c9f5-7c30-4cd0-86fb-32fdbecaa430'
    end

    def paye_hash
      {"paye": [
        {
          "taxYear": "18-19",
          "employee": {
            "hasPartner": true
          },
          "payFrequency": "W4",
          "weeklyPeriodNumber": "2",
          "monthlyPeriodNumber": "3",
          "paymentDate": "2006-02-27",
          "taxCode": "K971",
          "taxablePayToDate": 19157.5,
          "totalTaxToDate": 3095.89,
          "taxablePay": 16533.95,
          "taxDeductedOrRefunded": 159228.49,
          "employeePensionContribs": {
            "paidYTD": 169731.51,
            "notPaidYTD": 173987.07,
            "paid": 822317.49,
            "notPaid": 818841.65
          },
          "dednsFromNetPay": 198035.8,
          "statutoryPayYTD": {
            "maternity": 628562.9,
            "paternity": 98600.58,
            "adoption": 48703.26,
            "parentalBereavement": 39708.7
          },
          "grossEarningsForNICs": {
            "inPayPeriod1": 995979.04,
            "inPayPeriod2": 606456.38,
            "inPayPeriod3": 797877.34,
            "inPayPeriod4": 166334.69
          },
          "payroll": {
            "id": "}\\^W7 ci|)pENG;62$"
          },
          "employerPayeRef": "345/34678",
          "paidHoursWorked": "35",
          "totalEmployerNICs": {
            "inPayPeriod1": 18290.8,
            "inPayPeriod2": 192417.2,
            "inPayPeriod3": 14881.1,
            "inPayPeriod4": 17460.88,
            "ytd1": 530979.47,
            "ytd2": 197448.92,
            "ytd3": 172265.64,
            "ytd4": 122452.65
          },
          "employeeNICs": {
            "inPayPeriod1": 15797.45,
            "inPayPeriod2": 13170.69,
            "inPayPeriod3": 16193.76,
            "inPayPeriod4": 30846.56,
            "ytd1": 10633.5,
            "ytd2": 15579.18,
            "ytd3": 110849.27,
            "ytd4": 162081.23
          }
        }
      ]}.to_json
    end
  end
end
