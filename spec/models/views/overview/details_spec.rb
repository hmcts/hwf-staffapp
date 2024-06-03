require 'rails_helper'

RSpec.describe Views::Overview::Details do
  subject(:view) { described_class.new(application) }

  let(:application) { build_stubbed(:application) }
  let(:online_application) { build_stubbed(:online_application) }

  describe '#all_fields' do
    subject { view.all_fields }

    it do
      is_expected.to eql(['fee', 'jurisdiction', 'date_received', 'form_name', 'case_number',
                          'deceased_name', 'date_of_death', 'refund_request', 'date_fee_paid', 'discretion_applied',
                          'discretion_manager_name', 'discretion_reason', 'emergency_reason'])
    end

    context 'band calculation change active' do
      before { allow(FeatureSwitching).to receive(:active?).with(:band_calculation).and_return true }

      context 'paper application' do
        it "returns relevant fields" do
          is_expected.to eql(['fee', 'jurisdiction', 'form_name', 'case_number',
                              'deceased_name', 'date_of_death', 'emergency_reason'])
        end
      end

      context 'digital application' do
        let(:application) { build_stubbed(:online_application) }
        it "returns relevant fields" do
          is_expected.to eql(['fee', 'jurisdiction', 'form_name', 'case_number',
                              "discretion_applied", 'deceased_name', 'date_of_death', 'emergency_reason'])
        end
      end
    end
  end

  describe '#fee' do
    subject { view.fee }

    let(:application) { build_stubbed(:application, fee: fee_amount) }

    context 'display 2 decimal places' do
      let(:fee_amount) { 1005.49 }

      it 'formats the fee amount correctly' do
        is_expected.to eq '£1,005.49'
      end
    end
  end

  describe '#medium' do
    subject { view.medium }

    context 'online application' do
      let(:application) { build_stubbed(:online_application) }
      it { is_expected.to eq 'digital' }
    end
    context 'paper application' do
      let(:application) { build_stubbed(:application) }
      it { is_expected.to eq 'paper' }
    end

  end

  describe '#date_received' do
    let(:detail) { build_stubbed(:detail, date_received: Time.zone.parse('2015-11-20')) }
    let(:application) { build_stubbed(:application, detail: detail) }

    it 'formats the date correctly' do
      expect(view.date_received).to eql('20 November 2015')
    end
  end

  describe '#date_of_death' do
    let(:detail) { build_stubbed(:detail, date_of_death: Time.zone.parse('2015-11-20')) }
    let(:application) { build_stubbed(:application, detail: detail) }

    it 'formats the date correctly' do
      expect(view.date_of_death).to eql('20 November 2015')
    end
  end

  describe '#date_fee_paid' do
    let(:detail) { build_stubbed(:detail, date_fee_paid: Time.zone.parse('2015-11-20')) }
    let(:application) { build_stubbed(:application, detail: detail) }

    it 'formats the date correctly' do
      expect(view.date_fee_paid).to eql('20 November 2015')
    end
  end

  describe '#jurisdiction' do
    subject { view.jurisdiction }

    let(:jurisdiction) { build_stubbed(:jurisdiction) }
    let(:application) { build_stubbed(:application, jurisdiction: jurisdiction) }

    it { is_expected.to eq jurisdiction.name }
  end

  describe 'delegated methods' do
    describe '-> Detail' do
      [:form_name, :case_number, :deceased_name, :emergency_reason].each do |getter|
        it { expect(view.public_send(getter)).to eql(application.detail.public_send(getter)) }
      end
    end
  end

  describe 'discretion_applied' do
    context 'online_application' do
      subject(:view) { described_class.new(online_application) }
      it "return nil" do
        expect(view.discretion_applied).to be_nil
      end
    end

    context 'application' do
      let(:application) { build_stubbed(:application, detail: detail) }
      let(:detail) { build_stubbed(:detail, discretion_applied: true) }

      it "return nil" do
        expect(view.discretion_applied).to eql('Yes')
      end
    end
  end
end
