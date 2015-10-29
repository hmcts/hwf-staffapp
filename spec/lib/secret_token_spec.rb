require 'rails_helper'

RSpec.describe SecretToken do
  describe '.generate' do
    let(:token) { 'foo' }

    subject { described_class.generate }

    context 'when in production' do
      it 'returns the correct secret token' do
        ClimateControl.modify SECRET_TOKEN: token do
          allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
          expect(subject).to eq token
        end
      end
    end

    context 'when not in production' do
      it { expect(subject).to eq ('a' * 30) }
    end
  end
end
