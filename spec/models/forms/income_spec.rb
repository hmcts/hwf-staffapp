require 'rails_helper'

RSpec.describe Forms::Income do
  params_list = %i[income dependents children]

  subject { described_class.new(hash) }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validation' do
    describe 'dependents' do
      hash = {}
      let(:income) { described_class.new(hash) }

      context 'when true' do
        before { income[:dependents] = true }

        it { expect(income.valid?).to be true }
      end

      context 'when false' do
        before { income[:dependents] = false }

        it { expect(income.valid?).to be true }
      end

      context 'when not a boolean value' do
        before { income[:dependents] = 'string' }

        it { expect(income.valid?).to be false }
      end
    end

  end
end
