require 'rails_helper'

RSpec.describe Evidence::Forms::Income do
  params_list = %i[income]

  let(:income) { { income: '500' } }
  subject { described_class.new(income) }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validation' do
    it { is_expected.to validate_presence_of(:income) }

    context 'when the income is 0' do
      let(:income) { { income: '0' } }

      it { expect(subject.valid?).to be true }
    end

    context 'when the income is negative' do
      let(:income) { { income: '-1' } }

      it { expect(subject.valid?).to be false }
    end

    context 'when the income is string' do
      let(:income) { { income: 'a string' } }

      it { expect(subject.valid?).to be false }
    end
  end
end
