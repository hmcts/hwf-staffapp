require 'rails_helper'

describe ProcessDwpService do

  before { WebMock.disable_net_connect!(allow: 'codeclimate.com') }

  context 'called with invalid object' do
    it 'fails' do
      expect {
        described_class.new(nil)
      }.to raise_error
    end
  end
  context 'called with valid object' do
    context 'with valid params' do

      let(:user) { FactoryGirl.create(:user) }
      let(:check) { FactoryGirl.create(:dwp_check, created_by_id: user.id, dob: '19800101', ni_number: 'AB123456A', last_name: 'LAST_NAME') }
      before(:each) do
        json = '{"original_client_ref": "' + check.our_api_token + '", "benefit_checker_status": "Yes",
               "confirmation_ref": "T1426267181940",
               "@xmlns": "https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check"}'
        stub_request(:post, "#{ENV['DWP_API_PROXY']}/api/benefit_checks").
          with(body: { id: check.our_api_token, birth_date: '19800101', entitlement_check_date: Date.today.strftime('%Y%m%d'), ni_number: 'AB123456A', surname: 'LAST_NAME' }).
          to_return(status: 200, body: json, headers: {})
        described_class.new(check)
      end
      it 'succeeds' do
        expect {
          described_class.new(check)
        }.not_to raise_error
      end

      it 'sets the dwp_result' do
        expect(check.dwp_result).to eql('Yes')
      end

      it 'sets the benefits valid' do
        expect(check.benefits_valid).to eql(true)
      end

      it 'sets the dwp_id' do
        expect(check.dwp_id).to eql('T1426267181940')
      end
    end

    context 'simulating a 500 error' do
      it 'returns the error' do
        user = FactoryGirl.create(:user)
        check = FactoryGirl.create(:dwp_check, created_by_id: user.id, dob: '19800101', ni_number: 'AB123456A', last_name: 'LAST_NAME')
        stub_request(:post, "#{ENV['DWP_API_PROXY']}/api/benefit_checks").
          to_return(status: 500, headers: {})

        expect {
          described_class.new(check)
        }.to raise_error
      end
    end
  end
end
