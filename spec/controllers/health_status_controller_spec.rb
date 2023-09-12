require 'rails_helper'

RSpec.describe HealthStatusController do

  describe 'GET #ping' do
    before { get :ping }

    it 'returns success code' do
      expect(response).to have_http_status(:success)
    end

    it 'returns JSON' do
      expect(response.content_type).to eq('application/json; charset=utf-8')
    end

    describe 'renders correct json' do
      let(:json) { response.parsed_body }
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

  describe '#show' do
    let(:json) { { status: 'ok' } }
    let(:health_check) { instance_double(HealthStatus::HealthCheck, as_json: json, healthy?: healthy?) }

    before do
      allow(HealthStatus::HealthCheck).to receive(:new).and_return(health_check)

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

    # context 'when the health check reports as unhealthy' do
    #   let(:healthy?) { false }

    #   it 'responds with 500 status' do
    #     expect(response).to have_http_status(:internal_server_error)
    #   end

    #   it 'renders the health check json' do
    #     expect(response.body).to eql(json.to_json)
    #   end
    # end
  end

  describe 'GET #raise_exception' do
    it { expect { get :raise_exception }.to raise_exception(RuntimeError) }
  end

  describe 'GET #healthcheck' do
    context 'when all the components are operational' do
      before do
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
        allow(HealthStatus).to receive(:current_status).and_return(hash)
        get :healthcheck
      end

      it 'returns JSON' do
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end

      it 'completes with status code 200' do
        expect(response).to have_http_status 200
      end
    end

    context 'when database is down' do
      before do
        hash = {
          ok: false,
          database: {
            description: "Postgres database",
            ok: false
          }
        }
        allow(HealthStatus).to receive(:current_status).and_return(hash)
        get :healthcheck
      end

      it 'returns JSON' do
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end

      it 'completes with error status code 500' do
        expect(response).to have_http_status 500
      end
    end

    context 'when SMTP server is down' do
      before do
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
        allow(HealthStatus).to receive(:current_status).and_return(hash)
        get :healthcheck
      end

      it 'returns JSON' do
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end

      it 'completes with error status code 500' do
        expect(response).to have_http_status 500
      end
    end

    context 'when DWP proxy API is up' do

      before {
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
        allow(HealthStatus).to receive(:current_status).and_return(hash)
        get :healthcheck
      }

      it 'completes successfully' do
        expect(response).to have_http_status 200
      end
    end

    context 'when DWP proxy API is down' do
      before do
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
        allow(HealthStatus).to receive(:current_status).and_return(hash)
        get :healthcheck
      end

      it 'completes with error status code 500' do
        expect(response).to have_http_status 500
      end
    end
  end
end
