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
    # api/new/user
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
        body: {"firstName": "Mercer","lastName": "Draper","nino": "RC729233D","dateOfBirth": "1962-03-28"}.to_json,
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
    # from date and end date has to match exactly
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
          fromDate: '2019-01-01',
          toDate: '2019-03-31'
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

    # works but date scope need to be exact
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
          fromDate: '2019-01-01',
          toDate: '2019-03-31'
        },
        debug_output: STDOUT
      )

      render json: party
    end

    # works
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
          fromTaxYear: '2019-20'
        },
        debug_output: STDOUT
      )

      render json: party
    end

    # works but toTaxYear need to be present to get the results
    # summary returns income of selfAssesments not sum of all the other incomes like dividends,trusts,...
    # api/incomes/sa/summary
    def sa_summary
      # /individuals/income/sa/summary?matchId=38b1e003-f07e-47f7-bd2a-53c6e7033ed7{&fromTaxYear,toTaxYear}
      party = HTTParty.get("https://test-api.service.hmrc.gov.uk/individuals/income/sa/summary",
        headers: {
              "Content-Type": "application/json",
              "Accept": "application/vnd.hmrc.2.0+json",
              "Authorization": access_token,
              "correlationId": UUID.new.generate},
        query: {
          matchId: match_id,
          fromTaxYear: '2018-19',
          toTaxYear: '2019-20'
        },
        debug_output: STDOUT
      )

      render json: party
    end

    # works
    # api/incomes/sa/self
    def sa_self
      # /individuals/income/sa/self-employments
      party = HTTParty.get("https://test-api.service.hmrc.gov.uk/individuals/income/sa/self-employments",
        headers: {
              "Content-Type": "application/json",
              "Accept": "application/vnd.hmrc.2.0+json",
              "Authorization": access_token,
              "correlationId": UUID.new.generate},
        query: {
          matchId: match_id,
          fromTaxYear: '2018-19',
          toTaxYear: '2019-20'
        },
        debug_output: STDOUT
      )

      render json: party
    end

    # - Insufficient Enrolments - do we need this?
    # api/incomes/sa/trust
    def sa_trust
      # /individuals/income/sa/trust
      party = HTTParty.get("https://test-api.service.hmrc.gov.uk/individuals/income/sa/trusts",
        headers: {
              "Content-Type": "application/json",
              "Accept": "application/vnd.hmrc.2.0+json",
              "Authorization": access_token,
              "correlationId": UUID.new.generate},
        query: {
          matchId: match_id,
          fromTaxYear: '2018-19',
          toTaxYear: '2019-20'
        },
        debug_output: STDOUT
      )

      render json: party
    end

    # works - but need the toTaxYear too
    # api/incomes/sa/properties
    def sa_properties
      # /individuals/income/sa/trust
      party = HTTParty.get("https://test-api.service.hmrc.gov.uk/individuals/income/sa/uk-properties",
        headers: {
              "Content-Type": "application/json",
              "Accept": "application/vnd.hmrc.2.0+json",
              "Authorization": access_token,
              "correlationId": UUID.new.generate},
        query: {
          matchId: match_id,
          fromTaxYear: '2018-19',
          toTaxYear: '2019-20'
        },
        debug_output: STDOUT
      )

      render json: party
    end

    # works - but need the toTaxYear too
    # api/incomes/sa/foreign
    def sa_foreign
      # /individuals/income/sa/foreign
      party = HTTParty.get("https://test-api.service.hmrc.gov.uk/individuals/income/sa/foreign",
        headers: {
              "Content-Type": "application/json",
              "Accept": "application/vnd.hmrc.2.0+json",
              "Authorization": access_token,
              "correlationId": UUID.new.generate},
        query: {
          matchId: match_id,
          fromTaxYear: '2018-19',
          toTaxYear: '2019-20'
        },
        debug_output: STDOUT
      )

      render json: party
    end

    # works - but need the toTaxYear too
    # api/incomes/sa/dividends
    def sa_dividends
      # /individuals/income/sa/interests-and-dividends
      party = HTTParty.get("https://test-api.service.hmrc.gov.uk/individuals/income/sa/interests-and-dividends",
        headers: {
              "Content-Type": "application/json",
              "Accept": "application/vnd.hmrc.2.0+json",
              "Authorization": access_token,
              "correlationId": UUID.new.generate},
        query: {
          matchId: match_id,
          fromTaxYear: '2018-19',
          toTaxYear: '2019-20'
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

    # works but empty fields
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
          toDate: '2018-10-01'
        },
        debug_output: STDOUT
      )

      render json: party
    end

    # works but empty - don't know how to create test data for this
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
          fromDate: '2018-02-02',
          toDate: '2018-10-01'
        },
        debug_output: STDOUT
      )

      render json: party
    end

    # works but empty - don't know how to create test data for this
    # api/details/address
    def details_address
      # /individuals/benefits-and-credits/child-tax-credit?matchId=27e51b22-9e56-4767-a952-1ff4173427f7{&fromDate,toDate}
      party = HTTParty.get("https://test-api.service.hmrc.gov.uk/individuals/details/addresses",
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

    # CREATE TEST DATA

    # api/new/employment
    # works
    def create_employment
      party = HTTParty.post('https://test-api.service.hmrc.gov.uk/individuals/integration-framework-test-support/individuals/employment/nino/RC729233D',
        headers: {
          "Content-Type": "application/json",
          "Accept" => "application/vnd.hmrc.1.0+json",
          "Authorization" => access_token },
          query:  {
            useCase: 'HMCTS-C4',
            startDate: '2019-01-01',
            endDate: '2019-03-31'
          },
          body: { "employments": [
                  {
                    "employer": {
                      "name": "HMCTS-C4 Industries Limited",
                      "address": {
                        "line1": "Unit 23",
                        "line2": "Utilitarian Industrial Park",
                        "line3": "Utilitown",
                        "line4": "County Durham",
                        "line5": "UK",
                        "postcode": "DH4 4YY"
                      },
                      "districtNumber": "247",
                      "schemeRef": "ZT65A"
                    },
                    "employment": { "startDate": "2019-01-01",  "endDate": "2019-03-31" }
                  }
          ]}.to_json,
          debug_output: STDOUT)

        render json: party
    end


    # api/new/paye
    # works
    def create_paye
      party = HTTParty.post('https://test-api.service.hmrc.gov.uk/individuals/integration-framework-test-support/individuals/income/paye/nino/RC729233D',
        headers: {
         "Content-Type": "application/json",
         "Accept" => "application/vnd.hmrc.1.0+json",
         "Authorization" => access_token },
          query:  {
            useCase: 'HMCTS-C4',
            startDate: '2019-04-01',
            endDate: '2019-04-30'
          },
          body: { "paye": [
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
  ]}.to_json,
          debug_output: STDOUT)

        render json: party
    end

    # api/new/benefits
    # works
    def create_benefits
      party = HTTParty.post('https://test-api.service.hmrc.gov.uk/individuals/integration-framework-test-support/individuals/tax-credits/nino/RC729233D',
        headers: {
         "Content-Type": "application/json",
         "Accept" => "application/vnd.hmrc.1.0+json",
         "Authorization" => access_token
        },
        query: {
          "useCase" => 'HMCTS-C2-child-tax-credit',
          startDate: '2018-02-02',
          endDate: '2018-10-01',
        },
        body: {
        "applications": [
    {
      "id": 72105654,
      "awards": [
        {
          "totalEntitlement": 18765.23,
          "payProfCalcDate": "2020-11-18",
          "workingTaxCredit": {
            "amount": 930.98,
            "paidYTD": 8976.34
          },
          "childTaxCredit": {
            "childCareAmount": 930.98,
            "ctcChildAmount": 730.49,
            "familyAmount": 100.49,
            "babyAmount": 100,
            "paidYTD": 8976.34
          },
          "payments": [
            {
              "startDate": "2018-01-01",
              "endDate": "2018-05-01",
              "frequency": 7,
              "tcType": "ETC",
              "amount": 76.34
            },
            {
              "startDate": "2018-06-01",
              "endDate": "2018-10-01",
              "frequency": 7,
              "tcType": "ETC",
              "amount": 76.34
            }
          ]
        }
      ]
    }
  ]}.to_json,
          debug_output: STDOUT)

        render json: party
    end

    def create_sa
      party = HTTParty.post('https://test-api.service.hmrc.gov.uk/individuals/integration-framework-test-support/individuals/income/sa/nino/RC729233D',
        headers: {
         "Content-Type": "application/json",
         "Accept" => "application/vnd.hmrc.1.0+json",
         "Authorization" => access_token
        },
        query: {
          useCase: 'HMCTS-C2',
          startYear: '2019',
          endYear: '2020',
        },
        body: {
          "sa": [
              {
                "taxYear": "2019",
                "returnList": [
                  {
                    "busStartDate": "2018-02-21",
                    "busEndDate": "2018-02-22",
                    "caseStartDate": "2018-02-20",
                    "receivedDate": "2018-02-20",
                    "businessDescription": "Dogs body",
                    "address": {
                      "line1": "ap",
                      "line2": "ao",
                      "line3": "ai",
                      "line4": "au",
                      "postcode": "NE65 0UH"
                    },
                    "telephoneNumber": "0191111222",
                    "income": {
                      "selfAssessment": 100.99,
                      "trusts": 1.98,
                      "allEmployments": 0,
                      "selfEmployment": 100.97,
                      "partnerships": 1.96,
                      "ukProperty": 2.95,
                      "foreign": 3.94,
                      "foreignDivs": 4.93,
                      "ukInterest": 0.92,
                      "ukDivsAndInterest": 1.91,
                      "pensions": 3.90,
                      "other": 6.89,
                      "lifePolicies": 7.88,
                      "shares": 8.87
                    },
                    "totalTaxPaid": 99.99,
                    "totalNIC": 1.99,
                    "turnover": 345435.03,
                    "otherBusIncome": 34545.88,
                    "tradingIncomeAllowance": 100,
                    "deducts": {
                      "totalBusExpenses": 0.86,
                      "totalDisallowBusExp": 0.85
                    }
                  }
                ]
              }
            ]
        }.to_json,
          debug_output: STDOUT)

        render json: party
    end

    # api/new/contact
    # works
    def create_contact
      party = HTTParty.post('https://test-api.service.hmrc.gov.uk/individuals/integration-framework-test-support/individuals/details/contact/nino/RC729233D',
        headers: {
          "Content-Type": "application/json",
          "Accept" => "application/vnd.hmrc.1.0+json",
          "Authorization" => access_token },
          query:  {
            useCase: 'HMCTS-C3-residences'
          },
          body: {
            "residences": [
              {
                "type": "BASE",
                "address": {
                  "line1": "75 Trinity Street",
                  "line2": "1 Dawley Bank",
                  "line3": "Telford",
                  "line4": "Shropshire",
                  "line5": "UK",
                  "postcode": "TF2 4AR"
                },
                "noLongerUsed": "N"
              }
            ]}.to_json,
          debug_output: STDOUT)

        render json: party
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
      'Bearer fdc762b23dfa3df0e487cb3a8ebeb196'
    end

    def match_id
      '4f06f48b-ddb9-4acc-8307-89f0cf006339'
    end


  end
end
