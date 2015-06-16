require 'rails_helper'

describe HealthStatus do

  before { WebMock.disable_net_connect!(allow: 'codeclimate.com') }

  describe '.current_status' do
    describe 'DWP API' do
      context "when it's down" do
        let(:failure) do
          {
            ok: false,
            database: {
              description: 'Postgres database',
              ok: false
            },
            smtp: {
              description: 'SMTP server',
              ok: false
            },
            api: {
              description: 'DWP API',
              ok: false
            }
          }
        end

        it 'returns false' do
          expect(HealthStatus).to receive(:smtp).and_return(false)
          expect(HealthStatus).to receive(:database).and_return(false)
          expect(HealthStatus).to receive(:api).and_return(false)
          expect(described_class.current_status).to eq failure
        end
      end

      context "when it's working" do
        let(:success) do
          {
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
        end

        it 'returns true' do
          expect(HealthStatus).to receive(:smtp).and_return(true)
          expect(HealthStatus).to receive(:database).and_return(true)
          expect(HealthStatus).to receive(:api).and_return(true)
          expect(described_class.current_status).to eq success
        end
      end
    end
  end
end
