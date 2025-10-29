module BenefitCheckers
  class MockApiClient < BaseClient
    def check(params)
      ni_number = params[:ni_number]
      {
        'benefit_checker_status' => mock_status(ni_number),
        'confirmation_ref' => "MOCK-T1426267181940"
      }.with_indifferent_access
    end

    private

    # rubocop:disable Metrics/MethodLength
    def mock_status(ni_number)
      case ni_number
      when *Settings.dwp_mock.ni_number_yes
        'Yes'
      when *Settings.dwp_mock.ni_number_no
        'No'
      when *Settings.dwp_mock.ni_number_undetermined
        raise Exceptions::UndeterminedDwpCheck
      when *Settings.dwp_mock.ni_number_dwp_error
        raise RestClient::BadRequest, '{"error":"LSCBC MOCK service is currently unavailable"}'
      when *Settings.dwp_mock.ni_number_500_error
        raise StandardError, '500 Internal Server Error'
      when *Settings.dwp_mock.ni_number_connection_refused
        raise Errno::ECONNREFUSED, 'Connection refused'
      else
        ''
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
