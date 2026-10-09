module BenefitCheckers
  # Keeps every DWP call, answered or failed, on the benefit check as a DwpApiCall
  class DwpApiCallRecorder
    include DwpApiErrorHandler

    def initialize(benefit_check)
      @benefit_check = benefit_check
    end

    def record(endpoint_name, request_params, response_data)
      return unless @benefit_check

      DwpApiCall.create(benefit_check: @benefit_check, endpoint_name: endpoint_name,
                        request_params: request_params, data: response_data)
    end

    def record_error(endpoint_name, request_params, error)
      record(endpoint_name, request_params, parse_error_data(error))
    end
  end
end
