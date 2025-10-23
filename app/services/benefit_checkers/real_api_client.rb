module BenefitCheckers
  class RealApiClient < BaseClient
    def check(params)
      JSON.parse(
        RestClient.post(
          "#{ENV.fetch('DWP_API_PROXY', nil)}/api/benefit_checks",
          params
        )
      )
    end
  end
end
