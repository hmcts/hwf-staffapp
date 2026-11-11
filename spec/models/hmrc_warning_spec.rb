require 'rails_helper'

RSpec.describe HmrcWarning do
  let(:hmrc_warning) { build(:hmrc_warning) }

  it "has a default value" do
    expect(hmrc_warning.check_state).to eql(HmrcWarning::STATES[:default_checker])
  end

  it 'allows only one record' do
    create(:hmrc_warning)

    expect { create(:hmrc_warning) }.to raise_error(ActiveRecord::RecordNotSaved)
  end

  describe 'Use default check?' do
    it { expect(described_class.use_default_check?).to be_truthy }

    context 'online' do
      before { create(:hmrc_warning, check_state: HmrcWarning::STATES[:online]) }

      it { expect(described_class.use_default_check?).to be_falsey }
    end

    context 'offline' do
      before { create(:hmrc_warning, check_state: HmrcWarning::STATES[:offline]) }

      it { expect(described_class.use_default_check?).to be_falsey }
    end
  end

  describe '#state' do
    context 'when there is no record' do
      it { expect(described_class.state).to be_nil }
    end

    context 'online' do
      before { create(:hmrc_warning, check_state: HmrcWarning::STATES[:online]) }

      it { expect(described_class.state).to eql('online') }
    end

    context 'offline' do
      before { create(:hmrc_warning, check_state: HmrcWarning::STATES[:offline]) }

      it { expect(described_class.state).to eql('offline') }
    end

    context 'default_checker' do
      before { create(:hmrc_warning, check_state: HmrcWarning::STATES[:default_checker]) }

      it { expect(described_class.state).to eql('default_checker') }
    end
  end

  describe '.checker_state' do
    let(:hmrc_monitor) { instance_double(HmrcMonitor, state: 'offline') }

    before { allow(HmrcMonitor).to receive(:new).and_return(hmrc_monitor) }

    context 'when there is no record' do
      it 'uses the monitor' do
        expect(described_class.checker_state).to eql('offline')
      end
    end

    context 'when the switch is on the default checker' do
      before { create(:hmrc_warning, check_state: HmrcWarning::STATES[:default_checker]) }

      it 'uses the monitor' do
        expect(described_class.checker_state).to eql('offline')
      end
    end

    context 'when the switch is online and the monitor is offline' do
      before { create(:hmrc_warning, check_state: HmrcWarning::STATES[:online]) }

      it 'uses the switch' do
        expect(described_class.checker_state).to eql('online')
      end
    end

    context 'when the switch is offline and the monitor is online' do
      let(:hmrc_monitor) { instance_double(HmrcMonitor, state: 'online') }

      before { create(:hmrc_warning, check_state: HmrcWarning::STATES[:offline]) }

      it 'uses the switch' do
        expect(described_class.checker_state).to eql('offline')
      end
    end
  end

  describe '.checker_offline?' do
    let(:hmrc_monitor) { instance_double(HmrcMonitor, state: monitor_state) }
    let(:monitor_state) { 'online' }

    before { allow(HmrcMonitor).to receive(:new).and_return(hmrc_monitor) }

    context 'when the monitor is offline and there is no switch' do
      let(:monitor_state) { 'offline' }

      it { expect(described_class.checker_offline?).to be true }
    end

    context 'when the monitor is offline and the switch is online' do
      let(:monitor_state) { 'offline' }

      before { create(:hmrc_warning, check_state: HmrcWarning::STATES[:online]) }

      it { expect(described_class.checker_offline?).to be false }
    end

    context 'when the monitor is only warning' do
      let(:monitor_state) { 'warning' }

      it { expect(described_class.checker_offline?).to be false }
    end

    context 'when the monitor is online and the switch is offline' do
      before { create(:hmrc_warning, check_state: HmrcWarning::STATES[:offline]) }

      it { expect(described_class.checker_offline?).to be true }
    end
  end
end
