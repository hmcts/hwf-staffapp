require 'rails_helper'

RSpec.describe Forms::SavingsInvestment do
  params_list = %i[threshold_exceeded]

  let(:application) { create :application }

  subject { described_class.new(application) }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validations' do
    describe 'threshold_exceeded' do
      let(:savings_investment) { described_class.new(hash) }

      describe 'when false' do
        let(:hash) { { threshold_exceeded: false } }

        it { expect(savings_investment).to be_valid  }
      end

      describe 'when true' do
        let(:hash) { { threshold_exceeded: true } }

        it { expect(savings_investment).to be_valid  }
      end

      describe 'when something other than true of false' do
        let(:hash) { { threshold_exceeded: 'blah' } }

        it { expect(savings_investment).not_to be_valid  }
      end
    end
  end
end
