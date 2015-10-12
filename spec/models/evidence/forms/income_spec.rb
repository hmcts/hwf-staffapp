require 'rails_helper'

RSpec.describe Evidence::Forms::Income do
  params_list = %i[id amount]

  let(:amount) { '500' }
  let(:income) { { id: 1, amount: amount } }

  subject { described_class.new(income) }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validation' do
    context 'when the income is 0' do
      let(:amount) { '0' }

      it { expect(subject.valid?).to be true }
    end

    context 'when the income is negative' do
      let(:amount) { '-1' }

      it { expect(subject.valid?).to be false }
    end

    context 'when the income is string' do
      let(:amount) { 'a string' }

      it 'does not pass validation' do
        expect(subject.valid?).to be false
      end
    end

    context 'when the income is blank' do
      let(:amount) { '' }

      it 'does not pass validation' do
        expect(subject.valid?).to be false
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
