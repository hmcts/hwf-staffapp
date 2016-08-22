require 'rails_helper'

RSpec.describe Views::Overview::Details do

  let(:application) { build_stubbed(:application) }
  subject(:view) { described_class.new(application) }

  describe '#all_fields' do
    subject { view.all_fields }

    it { is_expected.to eql(%w[fee jurisdiction date_received form_name case_number deceased_name date_of_death date_fee_paid emergency_reason]) }
  end

  describe '#fee' do
    let(:application) { build_stubbed(:application, fee: fee_amount) }

    subject { view.fee }

    context 'rounds down' do
      let(:fee_amount) { 1005.49 }

      it 'formats the fee amount correctly' do
        is_expected.to eq '£1,005'
      end
    end

    context 'when its under £1' do
      let(:fee_amount) { 0.49 }

      it 'formats the fee amount correctly' do
        is_expected.to eq '£0'
      end
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
    let(:jurisdiction) { build_stubbed(:jurisdiction) }
    let(:application) { build_stubbed(:application, jurisdiction: jurisdiction) }

    subject { view.jurisdiction }

    it { is_expected.to eq jurisdiction.name }
  end

  describe 'delegated methods' do
    describe '-> Detail' do
      %i[form_name case_number deceased_name emergency_reason].each do |getter|
        it { expect(subject.public_send(getter)).to eql(application.detail.public_send(getter)) }
      end
    end
  end
end
