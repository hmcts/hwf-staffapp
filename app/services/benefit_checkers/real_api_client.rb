module BenefitCheckers
  class RealApiClient < BaseClient
    def check(params)
      response = connection.post('/api/benefit_checks') do |req|
        req.body = params
      end
      JSON.parse(response.body)
    rescue Faraday::BadRequestError => e
      parse_error_message(e)
    end

    private

    def connection
      @connection ||= Faraday.new(url: ENV.fetch('DWP_API_PROXY', nil)) do |conn|
        conn.request :url_encoded
        conn.response :raise_error
        conn.adapter Faraday.default_adapter
      end
    end

    def parse_error_message(error)
      begin
        error_message = error.response[:body]
      rescue StandardError
        error_message = error.message
      end
      raise BenefitCheckers::BadRequestError, error_message
    end
  end
end
