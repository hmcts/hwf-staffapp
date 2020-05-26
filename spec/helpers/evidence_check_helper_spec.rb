require 'rails_helper'

RSpec.describe EvidenceCheckHelper do
  let(:application) { build :application, :waiting_for_evidence_state, evidence_check: evidence, income: income1 }
  let(:evidence) { build :evidence_check, income: income2 }
  let(:income1) { nil }
  let(:income2) { nil }

  describe '#income_increase?' do
    context 'income is nil' do
      it 'returns false' do
        expect(income_increase?(application)).to be_falsey
      end
    end

    context 'original income is higher then new one' do
      let(:income1) { 2000 }
      let(:income2) { 1999 }

      it 'returns false' do
        expect(income_increase?(application)).to be_falsey
      end
    end

    context 'original income is lower then new one' do
      let(:income1) { 2000 }
      let(:income2) { 2001 }

      it 'returns false' do
        expect(income_increase?(application)).to be_truthy
      end
    end

    context 'original income is same as the new one' do
      let(:income1) { 2000 }
      let(:income2) { 2000 }

      it 'returns false' do
        expect(income_increase?(application)).to be_falsey
      end
    end
  end
end
