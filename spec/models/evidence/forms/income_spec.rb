require 'rails_helper'

RSpec.describe Evidence::Forms::Income do
  params_list = %i[income]

  let(:evidence) { build_stubbed :evidence_check }
  let(:income) { '500' }
  let(:params) { { income: income } }

  subject(:form) { described_class.new(evidence) }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validation' do
    before do
      form.update_attributes(params)
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
    let(:evidence) { create :evidence_check }
    let(:params) { { income: '500.5' } }
    let(:income_calculation_result) { { outcome: 'part', amount_to_pay: 100 } }
    let(:income_calculator) { double(calculate: income_calculation_result) }

    before do
      allow(IncomeCalculation).to receive(:new).with(evidence.application, 500).and_return(income_calculator)
      evidence.update_attributes(params)
    end

    subject { form.save }

    it 'saves the income on the evidence in the correct format' do
      subject && evidence.reload

      expect(evidence.income).to eql(500)
    end

    it 'saves the income on the income calculation outputs' do
      subject && evidence.reload

      expect(evidence.outcome).to eql(income_calculation_result[:outcome])
      expect(evidence.amount_to_pay).to eql(income_calculation_result[:amount_to_pay])
    end
  end
end
