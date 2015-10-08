require 'rails_helper'

RSpec.describe Evidence::Views::Evidence do

  subject(:evidence) { described_class.new(evidence_check) }

  describe 'correct' do
    let(:evidence_check) { build_stubbed(:evidence_check, correct: correct) }

    subject { evidence.correct }

    context 'when evidence is correct' do
      let(:correct) { true }

      it { is_expected.to eql('Yes') }
    end

    context 'when evidence is not correct' do
      let(:correct) { false }

      it { is_expected.to eql('No') }
    end
  end

  describe 'reason' do
    let(:evidence_check) { build_stubbed(:evidence_check, reason: reason) }

    subject { evidence.reason }

    context 'when reason exists' do
      let(:explanation) { 'EXPLANATION' }
      let(:reason) { build_stubbed(:reason, explanation: explanation) }

      it { is_expected.to eql(explanation) }
    end

    context 'when reason does not exists' do
      let(:reason) { nil }

      it { is_expected.to be nil }
    end
  end

  describe 'income' do
    let(:evidence_check) { build_stubbed(:evidence_check, income: income) }

    subject { evidence.income }

    context 'when income is set' do
      let(:income) { 200 }

      it { is_expected.to eql('£200') }
    end

    context 'when income is not set' do
      let(:income) { nil }

      it { is_expected.to be nil }
    end  end
end
