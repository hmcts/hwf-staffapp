require 'rails_helper'

RSpec.describe Views::Evidence do
  subject(:evidence) { described_class.new(evidence_check) }

  describe 'correct' do
    subject { evidence.correct }

    let(:evidence_check) { build_stubbed(:evidence_check, correct: correct) }

    context 'when evidence is correct' do
      let(:correct) { true }

      it { is_expected.to eql('Yes') }
    end

    context 'when evidence is not correct' do
      let(:correct) { false }

      it { is_expected.to eql('No') }
    end
  end

  describe 'incorrect_reason' do
    subject { evidence.incorrect_reason }

    let(:evidence_check) { build_stubbed(:evidence_check_incorrect) }

    it 'returns the incorrect reason from the evidence check' do
      is_expected.to eql(evidence_check.incorrect_reason)
    end
  end

  describe 'income' do
    subject { evidence.income }

    let(:evidence_check) { build_stubbed(:evidence_check, income: income) }

    context 'when income is set' do
      let(:income) { 200 }

      it { is_expected.to eql('£200') }
    end

    context 'when income is not set' do
      let(:income) { nil }

      it { is_expected.to be nil }
    end
  end
end
