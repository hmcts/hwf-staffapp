require 'rails_helper'

RSpec.describe ContactDwpHelper do
  before { WebMock.disable_net_connect!(allow: 'codeclimate.com') }
  let(:benefit_check) { create :benefit_check }

  before(:each) do
    json = '{"original_client_ref": "' + benefit_check.our_api_token + '", "benefit_checker_status": "Yes",
             "confirmation_ref": "T1426267181940",
             "@xmlns": "https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check"}'
    stub_request(:post, "#{ENV['DWP_API_PROXY']}/api/benefit_checks").
      to_return(status: 200, body: json, headers: {})
  end

  describe '#query_proxy_api' do
    it 'exists' do
      expect(helper).to respond_to :query_proxy_api
    end
  end

  describe '#params' do
    it 'exists' do
      expect(helper).to respond_to :params
    end

    context 'when passed a valid benefit check' do
      it 'returns a hash' do
        expect(BenefitCheckService.new(benefit_check).params).to be_a Hash
      end
    end
  end

  describe '#applicants_date_of_birth' do
    it 'exists' do
      expect(helper).to respond_to :applicants_date_of_birth
    end
  end

  describe '#process_check_date' do
    it 'exists' do
      expect(helper).to respond_to :process_check_date
    end
  end

  describe '#log_error' do
    it 'exists' do
      expect(helper).to respond_to :log_error
    end
  end

  describe '#check_remote_api' do
    it 'exists'do
      expect(helper).to respond_to :check_remote_api
    end
  end
end
