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
    let(:income) { described_class.new(hash) }

    describe 'dependents' do
      let(:hash) { { dependents: dependents, children: 1 } }

      context 'when true' do
        let(:dependents) { true }

        it { expect(income.valid?).to be true }
      end

      context 'when false' do
        let(:dependents) { false }

        it { expect(income.valid?).to be false }
      end

      context 'when not a boolean value' do
        let(:dependents) { 'string' }

        it { expect(income.valid?).to be false }
      end
    end

    describe 'children' do
      let(:hash) { { dependents: dependents, children: children } }

      context 'when there are dependents' do
        let(:dependents) { true }

        context 'and the number of children is valid' do
          let(:children) { 1 }

          it { expect(income.valid?).to be true }
        end

        context 'and the number of children is invalid' do
          let(:children) { 0 }

          it { expect(income.valid?).to be false }
        end
      end

      context 'when there are no dependents' do
        let(:dependents) { false }

        context 'and the number of children is bigger than zero' do
          let(:children) { 1 }

          it { expect(income.valid?).to be false }
        end

        context 'and the number of children is zero' do
          let(:children) { 0 }

          it { expect(income.valid?).to be true }
        end
      end
    end
  end
end
