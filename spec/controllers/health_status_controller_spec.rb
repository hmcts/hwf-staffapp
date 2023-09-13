require 'rails_helper'

RSpec.describe HealthStatusController do

  describe '#show' do
    let(:json) { { status: 'ok' } }

    before do
      get :show
    end

    context 'when the health check reports as healthy' do
      let(:healthy?) { true }

      it 'responds with 200 status' do
        expect(response).to have_http_status(:ok)
      end

      it 'renders the health check json' do
        expect(response.body).to eql(json.to_json)
      end
    end
  end

  describe 'GET #raise_exception' do
    it { expect { get :raise_exception }.to raise_exception(RuntimeError) }
  end
end
