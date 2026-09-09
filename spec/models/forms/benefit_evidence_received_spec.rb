require 'rails_helper'

RSpec.describe Forms::BenefitEvidenceReceived do
  subject(:form) { described_class.new({}) }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to eq([:evidence])
    end
  end

  describe 'validations' do
    subject { form.valid? }

    before { form.update(params) }

    context 'for attribute "evidence"' do
      let(:params) { { evidence: evidence } }

      context 'when not set' do
        let(:evidence) { nil }

        it { is_expected.to be false }
      end

      context 'for false' do
        let(:evidence) { false }

        it { is_expected.to be true }
      end

      context 'for true' do
        let(:evidence) { true }

        it { is_expected.to be true }
      end

      context 'for the string "true" from a radio button' do
        let(:evidence) { 'true' }

        it { is_expected.to be true }

        it 'casts the value to a boolean' do
          expect(form.evidence?).to be true
        end
      end
    end
  end
end
