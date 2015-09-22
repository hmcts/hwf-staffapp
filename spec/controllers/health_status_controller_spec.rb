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

  describe 'GET #raise_exception' do
    it { expect { get :raise_exception }.to raise_exception }
  end

  describe 'GET #healthcheck' do
    context 'when all the components are operational' do
      before(:each) do
        hash = {
          ok: true,
          database: {
            description: "Postgres database",
            ok: true
          },
          smtp: {
            description: "SMTP server",
            ok: true
          }
        }
        expect(HealthStatus).to receive(:current_status).and_return(hash)
        get :healthcheck
      end

      it 'returns JSON' do
        expect(response.content_type).to eq('application/json')
      end

      it 'completes with status code 200' do
        expect(response.status).to eq 200
      end
    end

    context 'when database is down' do
      before(:each) do
        hash = {
          ok: false,
          database: {
            description: "Postgres database",
            ok: false
          }
        }
        expect(HealthStatus).to receive(:current_status).and_return(hash)
        get :healthcheck
      end

      it 'returns JSON' do
        expect(response.content_type).to eq('application/json')
      end

      it 'completes with error status code 500' do
        expect(response.status).to eql 500
      end
    end

    context 'when SMTP server is down' do
      before(:each) do
        hash = {
          ok: false,
          database: {
            description: "Postgres database",
            ok: true
          },
          smtp: {
            description: "SMTP server",
            ok: false
          }
        }
        expect(HealthStatus).to receive(:current_status).and_return(hash)
        get :healthcheck
      end

      it 'returns JSON' do
        expect(response.content_type).to eq('application/json')
      end

      it 'completes with error status code 500' do
        expect(response.status).to eql 500
      end
    end

    context 'when DWP proxy API is up' do

      before(:each) {
        hash = {
          ok: true,
          database: {
            description: 'Postgres database',
            ok: true
          },
          smtp: {
            description: 'SMTP server',
            ok: true
          },
          api: {
            description: 'DWP API',
            ok: true
          }
        }
        expect(HealthStatus).to receive(:current_status).and_return(hash)
        get :healthcheck
      }

      it 'completes successfully' do
        expect(response.status).to eql 200
      end
    end

    context 'when DWP proxy API is down' do
      before(:each) do
        hash = {
          ok: false,
          database: {
            description: 'Postgres database',
            ok: true
          },
          smtp: {
            description: 'SMTP server',
            ok: true
          },
          api: {
            description: 'DWP API',
            ok: false
          }
        }
        expect(HealthStatus).to receive(:current_status).and_return(hash)
        get :healthcheck
      end

      it 'completes with error status code 500' do
        expect(response.status).to eql 500
      end
    end
  end
end
