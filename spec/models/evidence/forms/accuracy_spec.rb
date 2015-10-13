require 'rails_helper'

RSpec.describe Evidence::Forms::Accuracy do
  params_list = %i[correct reason]

  let(:evidence) { build_stubbed :evidence_check }
  subject(:form) { described_class.new(evidence) }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validations' do
    before do
      form.update_attributes(params)
    end

    subject { form.valid? }

    context 'for attribute "correct"' do
      context 'when true' do
        let(:params) { { correct: true } }

        it { is_expected.to be true }

        context 'if the reason had been set' do
          let(:params) { { correct: true, reason: 'some reason' } }

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
  end

  describe '#save' do
    let(:evidence) { create :evidence_check }

    before do
      form.update_attributes(params)
    end

    subject { form.save }

    context 'for an invalid form' do
      let(:params) { { correct: nil } }

      it { is_expected.to be false }
    end

    context 'for a valid form when the evidence is correct' do
      let(:params) { { correct: true } }

      it { is_expected.to be true }

      it 'updates the correct field on evidence check' do
        subject && evidence.reload

        expect(evidence.correct).to be true
      end

      it 'keeps the outcome empty' do
        subject && evidence.reload

        expect(evidence.outcome).to be nil
      end

      context 'if the reason already existed' do
        let(:evidence) { create :evidence_check_incorrect }

        it 'deletes the reason' do
          subject && evidence.reload

          expect(evidence.reason).to be nil
        end
      end
    end

    context 'for a valid form when the evidence is incorrect' do
      let(:reason) { 'REASON' }
      let(:params) { { correct: false, reason: reason } }

      it { is_expected.to be true }

      it 'updates the correct field on evidence check and creates reason record with explanation' do
        subject && evidence.reload

        expect(evidence.correct).to be false
        expect(evidence.reason.explanation).to eql(reason)
      end

      it 'sets the outcome to none' do
        subject && evidence.reload

        expect(evidence.outcome).to eql('none')
      end
    end
  end
end
