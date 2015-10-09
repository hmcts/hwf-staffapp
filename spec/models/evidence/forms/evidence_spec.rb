require 'rails_helper'

RSpec.describe Evidence::Forms::Evidence do
  params_list = %i[correct reason id]

  let(:evidence) { { correct: true } }
  subject(:evidence_form) { described_class.new(evidence) }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validations' do
    context 'for attribute "id"' do
      context 'when an integer' do
        let(:evidence) { { correct: true, id: 1 } }

        it { expect(subject.valid?).to be true }
      end

      context 'when not an integer' do
        let(:evidence) { { correct: true, id: 'foo' } }

        it { expect(subject.valid?).to be false }
      end

      context 'when not present' do
        let(:evidence) { { correct: true } }

        it { expect(subject.valid?).to be false }
      end
    end

    context 'for attribute "correct"' do
      context 'when true' do
        let(:evidence) { { correct: true, id: 1 } }

        it { expect(subject.valid?).to be true }

        context 'if the reason had been set' do
          let(:evidence) { { id: 1, correct: true, reason: 'some reason' } }

          it { expect(subject.valid?).to be true }
        end
      end

      context 'when false' do
        let(:evidence) { { correct: false, id: 1 } }

        it { expect(subject.valid?).to be true }
      end

      context 'when not a boolean value' do
        let(:evidence) { { correct: 'some string' } }

        it { expect(subject.valid?).to be false }
      end
    end
  end

  describe '#save', focus: true do
    let(:evidence_check) { create(:evidence_check) }
    subject { evidence_form.save }

    context 'for an invalid form' do
      let(:evidence) { {} }

      it { is_expected.to be false }
    end

    context 'for a valid form when the evidence is correct' do
      let(:evidence) { { id: evidence_check.id, correct: true } }

      it { is_expected.to be true }

      it 'updates the correct field on evidence check' do
        subject && evidence_check.reload

        expect(evidence_check.correct).to be true
      end

      it 'keeps the outcome empty' do
        subject && evidence_check.reload

        expect(evidence_check.outcome).to be nil
      end

      context 'if the reason already existed' do
        before do
          create :reason, evidence_check: evidence_check
        end

        it 'deletes the reason' do
          subject && evidence_check.reload

          expect(evidence_check.reason).to be nil
        end
      end
    end

    context 'for a valid form when the evidence is incorrect' do
      let(:reason) { 'REASON' }
      let(:evidence) { { id: evidence_check.id, correct: false, reason: reason } }

      it { is_expected.to be true }

      it 'updates the correct field on evidence check and creates reason record with explanation' do
        subject && evidence_check.reload

        expect(evidence_check.correct).to be false
        expect(evidence_check.reason.explanation).to eql(reason)
      end

      it 'sets the outcome to none' do
        subject && evidence_check.reload

        expect(evidence_check.outcome).to eql('none')
      end
    end
  end
end
