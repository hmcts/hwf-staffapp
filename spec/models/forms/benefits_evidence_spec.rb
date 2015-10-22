require 'rails_helper'

RSpec.describe Forms::BenefitsEvidence do
  params_list = %i[correct]

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  let(:benefit_override) { build_stubbed :benefit_override }

  subject(:form) { described_class.new(benefit_override) }

  describe 'validations' do
    before { form.update_attributes(params) }
    subject { form.valid? }

    context 'for attribute "correct"' do
      context 'when true' do
        let(:params) { { correct: true } }

        it { is_expected.to be true }
      end
    end

    context 'when false' do
      let(:params) { { correct: false } }

      it { is_expected.to be true }
    end

    context 'when not a boolean value' do
      let(:params) { { correct: 'some string' } }

      it { is_expected.to be false }
    end
  end

  describe '#save' do
    let(:application) { create :application }
    let(:benefit_override) { create :benefit_override, application: application }

    before { form.update_attributes(params) }

    subject { form.save }

    context 'for an invalid form' do
      let(:params) { { correct: nil } }

      it { is_expected.to be false }
    end

    context 'for a valid form when the evidence is correct' do
      context 'when true' do
        let(:params) { { correct: true } }

        it { is_expected.to be true }

        before { subject && benefit_override.reload }

        it 'updates the correct field on benefits_override' do
          expect(benefit_override.correct).to be true
        end
      end

      context 'when false' do
        let(:params) { { correct: false } }

        it { is_expected.to be true }

        before { subject && benefit_override.reload }

        it 'updates the correct field on benefit_override' do
          expect(benefit_override.correct).to be false
        end
      end
    end
  end
end
