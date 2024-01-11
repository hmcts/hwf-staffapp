require 'rails_helper'

RSpec.describe Forms::Evidence::Income do
  subject(:form) { described_class.new(evidence) }

  params_list = [:income]

  let(:evidence) { build_stubbed(:evidence_check) }
  let(:application) { create(:application, detail: detail) }
  let(:detail) { create(:detail) }
  let(:income) { '500' }
  let(:params) { { income: income } }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validation' do
    before do
      form.update(params)
    end

    subject { form.valid? }

    context 'when the income is above 0' do
      let(:income) { '100' }

      it { is_expected.to be true }
    end

    context 'when the income is 0' do
      let(:income) { '0' }

      it { is_expected.to be true }
    end

    context 'when the income is negative' do
      let(:income) { '-1' }

      it { is_expected.to be false }
    end

    context 'when the income is string' do
      let(:income) { 'a string' }

      it { is_expected.to be false }
    end

    context 'when the income is blank' do
      let(:income) { '' }

      it { is_expected.to be false }
    end
  end

  describe '#save' do
    subject(:form_save) { form.save }

    let(:evidence) { create(:evidence_check, application: application) }
    let(:params) { { income: '500.5' } }
    let(:income_calculation_result) { { outcome: 'part', amount_to_pay: 100, min_threshold: 1000, max_threshold: 5000 } }
    let(:income_calculator) { instance_double(IncomeCalculation, calculate: income_calculation_result) }

    before do
      allow(IncomeCalculation).to receive(:new).with(evidence.application, 500).and_return(income_calculator)
      evidence.update(params)
    end

    it 'saves the income on the evidence in the correct format' do
      form_save && evidence.reload

      expect(evidence.income).to eq 500
    end

    describe 'saves the income on the income calculation outputs' do
      before { form_save && evidence.reload }

      it { expect(evidence.outcome).to eql(income_calculation_result[:outcome]) }
      it { expect(evidence.amount_to_pay).to eql(income_calculation_result[:amount_to_pay]) }
    end
  end

  describe '#save post UCD' do
    subject(:form_save) { form.save }

    let(:detail) { create(:detail, calculation_scheme: FeatureSwitching::CALCULATION_SCHEMAS[1], fee: 150) }

    let(:evidence) { build(:evidence_check, application: application) }
    let(:application) { create(:application, detail: detail, income: 100) }
    let(:params) { { income: '1470' } }

    before do
      evidence.update(params)
    end

    it 'saves the income on the evidence in the correct format' do
      form_save && evidence.reload

      expect(evidence.income).to eq 1470
    end

    describe 'saves the income on the income calculation outputs' do
      before { form_save && evidence.reload }

      it { expect(evidence.outcome).to eql('part') }
      it { expect(evidence.amount_to_pay).to eq(25) }
    end

    context 'same income' do
      let(:params) { { income: '100' } }
      before { form_save && evidence.reload }

      it { expect(evidence.outcome).to eql('full') }
      it { expect(evidence.amount_to_pay).to eq(0) }

    end
  end
end
