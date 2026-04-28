require 'rails_helper'

RSpec.describe DwpApiCall do
  subject(:dwp_api_call) { build(:dwp_api_call) }

  describe 'associations' do
    it { is_expected.to belong_to(:benefit_check) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:endpoint_name) }
  end

  describe 'data storage' do
    let(:response_data) do
      {
        'data' => {
          'id' => 'abc-123-guid',
          'type' => 'Citizen',
          'attributes' => {
            'guid' => 'abc-123-guid',
            'benefitType' => 'universal_credit',
            'status' => 'in_payment'
          }
        }
      }
    end

    it 'stores and retrieves JSON response data' do
      dwp_api_call.data = response_data
      dwp_api_call.save!
      dwp_api_call.reload

      expect(dwp_api_call.data).to eq(response_data)
      expect(dwp_api_call.data.dig('data', 'attributes', 'status')).to eq('in_payment')
    end

    it 'stores and retrieves request params' do
      params = { last_name: 'SMITH', date_of_birth: '1985-06-15' }
      dwp_api_call.request_params = params
      dwp_api_call.save!
      dwp_api_call.reload

      expect(dwp_api_call.request_params['last_name']).to eq('SMITH')
    end
  end

  describe 'creation' do
    it 'can be created with valid attributes' do
      expect(dwp_api_call).to be_valid
    end

    it 'is invalid without an endpoint_name' do
      dwp_api_call.endpoint_name = nil
      expect(dwp_api_call).not_to be_valid
    end

    it 'allows nil data' do
      dwp_api_call.data = nil
      expect(dwp_api_call).to be_valid
    end

    it 'allows nil request_params' do
      dwp_api_call.request_params = nil
      expect(dwp_api_call).to be_valid
    end
  end
end
