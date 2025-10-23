module BenefitCheckers
  class MockApiClient < BaseClient
    def check(params)
      ni_number = params[:ni_number]
      {
        'benefit_checker_status' => mock_status(ni_number),
        'confirmation_ref' => "MOCK-#{SecureRandom.hex(8).upcase}"
      }.with_indifferent_access
    end

    private

    def mock_status(ni_number)
      case ni_number
      when Settings.dwp_mock.ni_number_yes
        'Yes'
      when Settings.dwp_mock.ni_number_no
        'No'
      when Settings.dwp_mock.ni_number_undetermined
        'Undetermined'
      else
        'BadRequest'
      end
    end
  end
end
