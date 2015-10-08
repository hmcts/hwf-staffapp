require 'rails_helper'

RSpec.describe Evidence::Forms::Income do
  params_list = %i[id amount]

  let(:income) { { id: 1, amount: '500' } }
  subject { described_class.new(income) }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validation' do
    context 'when the income is 0' do
      let(:income) { { amount: '0' } }

      it { expect(subject.valid?).to be true }
    end

    context 'when the income is negative' do
      let(:income) { { amount: '-1' } }

      it { expect(subject.valid?).to be false }
    end

    context 'when income is a Float' do
      before(:each) { subject.valid? }

      context 'round up' do
        let(:income) { { amount: '0.5' } }

        it { expect(subject.amount).to eq '1' }
      end

      context 'round down' do
        let(:income) { { amount: '0.49' } }

        it { expect(subject.amount).to eq '0' }
      end
    end

    context 'when the income is string' do
      before { subject.valid? }
      let(:income) { { amount: 'a string' } }

      it 'turns the string into 0' do
        expect(subject.amount).to eq '0'
      end
    end
  end

  describe '#save' do
    before do
      allow(subject).to receive(:valid?).and_return(true)
      allow(subject).to receive(:persist!)
      allow(EvidenceCheck).to receive(:find)
      allow_any_instance_of(EvidenceCheck).to receive(:update)
    end

    it 'saves the form data into appropriate models' do
      expect(subject.save).to eq true
    end
  end
end
