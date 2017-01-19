require 'rails_helper'

describe HealthStatus do

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
              description: 'SendGrid',
              ok: false
            },
            api: {
              description: 'DWP API',
              ok: false
            }
          }
        end

        before do
          allow(described_class).to receive(:smtp).and_return(false)
          allow(described_class).to receive(:database).and_return(false)
          allow(described_class).to receive(:api).and_return(false)
        end

        it { expect(described_class.current_status).to eq failure }
        it { expect(described_class.smtp).to be false }
        it { expect(described_class.database).to be false }
        it { expect(described_class.api).to be false }
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
              description: 'SendGrid',
              ok: true
            },
            api: {
              description: 'DWP API',
              ok: true
            }
          }
        end

        before do
          allow(described_class).to receive(:smtp).and_return(true)
          allow(described_class).to receive(:database).and_return(true)
          allow(described_class).to receive(:api).and_return(true)
        end

        it { expect(described_class.current_status).to eq success }
        it { expect(described_class.smtp).to be true }
        it { expect(described_class.database).to be true }
        it { expect(described_class.api).to be true }
      end
    end
  end
end
