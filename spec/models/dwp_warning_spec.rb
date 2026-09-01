require 'rails_helper'

RSpec.describe DwpWarning do
  let(:dwp_warning) { build(:dwp_warning) }

  it "has a default value" do
    expect(dwp_warning.check_state).to eql(DwpWarning::STATES[:default_checker])
  end

  describe 'Use default check?' do
    it { expect(described_class.use_default_check?).to be_truthy }

    context 'online' do
      before { create(:dwp_warning, check_state: DwpWarning::STATES[:online]) }

      it { expect(described_class.use_default_check?).to be_falsey }
    end

    context 'offline' do
      before { create(:dwp_warning, check_state: DwpWarning::STATES[:offline]) }

      it { expect(described_class.use_default_check?).to be_falsey }
    end
  end

  describe '#state' do

    context 'online' do
      before { create(:dwp_warning, check_state: DwpWarning::STATES[:online]) }

      it { expect(described_class.state).to eql('online') }
    end

    context 'offline' do
      before { create(:dwp_warning, check_state: DwpWarning::STATES[:offline]) }

      it { expect(described_class.state).to eql('offline') }
    end

    context 'default_checker' do
      before { create(:dwp_warning, check_state: DwpWarning::STATES[:default_checker]) }

      it { expect(described_class.state).to eql('default_checker') }
    end
  end

  describe '.offline?' do
    context 'when there is no record' do
      it { expect(described_class.offline?).to be false }
    end

    context 'when the state is offline' do
      before { create(:dwp_warning, check_state: DwpWarning::STATES[:offline]) }

      it { expect(described_class.offline?).to be true }
    end

    context 'when the state is online' do
      before { create(:dwp_warning, check_state: DwpWarning::STATES[:online]) }

      it { expect(described_class.offline?).to be false }
    end

    context 'when the state is default_checker' do
      before { create(:dwp_warning, check_state: DwpWarning::STATES[:default_checker]) }

      it { expect(described_class.offline?).to be false }
    end
  end
end
