require 'rails_helper'

RSpec.describe Forms::SavingsInvestment do
  params_list = %i[threshold_exceeded over_61 high_threshold_exceeded status application_id]

  let(:hash) { {} }

  subject { described_class.new(hash) }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validations' do
    let!(:application) { create :applicant_under_61 }

    describe 'threshold_exceeded' do
      describe 'when false' do
        let(:hash) { { threshold_exceeded: false, application_id: application.id } }

        it { is_expected.to be_valid  }
      end

      describe 'when true' do
        let(:hash) { { threshold_exceeded: true, over_61: false, application_id: application.id } }

        it { is_expected.to be_valid  }
      end

      describe 'when something other than true of false' do
        let(:hash) { { threshold_exceeded: 'blah', application_id: application.id } }

        it { is_expected.not_to be_valid  }
      end
    end

    describe "applicant's partner is over 61" do
      context 'if threshold is exceeded' do
        let(:hash) { { threshold_exceeded: true, over_61: partner_over_61, high_threshold_exceeded: true, application_id: application.id } }

        context 'when true' do
          let(:partner_over_61) { true }

          it { is_expected.to be_valid }
        end

        context 'when false' do
          let(:partner_over_61) { false }

          it { is_expected.to be_valid }
        end

        context 'when something other than true or false' do
          let(:partner_over_61) { 'invalid' }

          before { subject.valid? }

          it { is_expected.not_to be_valid }
        end
      end
    end

    describe 'high threshold' do
      let(:hash) { { threshold_exceeded: true, over_61: true, high_threshold_exceeded: high_threshold, application_id: application.id } }

      context 'is exceeded' do
        let(:high_threshold) { true }

        it { is_expected.to be_valid }
      end

      context 'is not exceeded' do
        let(:high_threshold) { false }

        it { is_expected.to be_valid }
      end

      context 'is not true or false' do
        let(:high_threshold) { 'invalid' }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
