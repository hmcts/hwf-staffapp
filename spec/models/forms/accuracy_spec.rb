require 'rails_helper'

RSpec.describe Forms::Accuracy do
  subject(:form) { described_class.new(evidence) }

  params_list = [:correct, :incorrect_reason, :incorrect_reason_category, :staff_error_details]

  let(:evidence) { build_stubbed(:evidence_check) }
  let(:application) { create(:application) }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validations' do
    before do
      form.update(params)
    end

    subject { form.valid? }

    context 'for attribute "correct"' do
      context 'when not a boolean value' do
        let(:params) { { correct: 'some string' } }

        # ActiveModel::Attributes coerces truthy strings to true
        it { is_expected.to be true }
      end
    end
  end

  describe '#save' do
    subject(:form_save) { form.save }

    let(:evidence) { create(:evidence_check, application: application) }

    before do
      form.update(params)
    end

    context 'for an invalid form' do
      let(:params) { { correct: nil } }

      it { is_expected.to be false }
    end

    context 'for a valid form when the evidence is correct' do
      let(:params) { { correct: true } }

      it { is_expected.to be true }

      before { form_save && evidence.reload }

      it 'updates the correct field on evidence check' do
        expect(evidence.correct).to be true
      end

      it 'keeps the incorrect reason empty' do
        expect(evidence.incorrect_reason).to be_nil
      end
    end

    context 'for a valid form when the evidence is incorrect' do
      let(:incorrect_reason) { 'REASON' }
      let(:params) { { correct: false, incorrect_reason: incorrect_reason } }

      it { is_expected.to be true }

      before { form_save && evidence.reload }

      describe 'updates the correct field on evidence check and creates reason record with explanation' do
        it { expect(evidence.correct).to be false }
        it { expect(evidence.incorrect_reason).to eql(incorrect_reason) }
      end
    end
  end
end
