require 'rails_helper'

RSpec.describe HealthStatusController, type: :controller do

  describe 'GET #ping' do
    before(:each) { get :ping }

    it 'returns success code' do
      expect(response).to have_http_status(:success)
    end

    it 'returns JSON' do
      expect(response.content_type).to eq('application/json')
    end

    describe 'renders correct json' do
      let(:json) { JSON.parse(response.body) }
      let(:keys) do
        ["version_number",
         "build_date",
         "commit_id",
         "build_tag"]
      end

      it 'has ping.json schema defined keys' do
        expect(json.keys).to eq keys
      end

      it 'key count' do
        expect(json.count).to eq 4
      end
    end
  end
end
