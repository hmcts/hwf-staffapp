require 'rails_helper'

RSpec.describe Applikation::Forms::SavingsInvestment do
  params_list = %i[threshold_exceeded partner_over_61 high_threshold_exceeded]

  subject { described_class.new(application) }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validations' do
    let!(:application) { create :applicant_under_61 }

    before do
      subject.update_attributes(hash)
    end

    describe 'threshold_exceeded' do
      describe 'when false' do
        let(:hash) { { threshold_exceeded: false } }

        it { is_expected.to be_valid  }
      end

      describe 'when true' do
        let(:hash) { { threshold_exceeded: true, partner_over_61: false } }

        it { is_expected.to be_valid  }
      end

      describe 'when something other than true of false' do
        let(:hash) { { threshold_exceeded: 'blah' } }

        it { is_expected.not_to be_valid  }
      end
    end

    describe "applicant's partner is over 61" do
      context 'if threshold is exceeded' do
        let(:hash) { { threshold_exceeded: true, partner_over_61: partner_partner_over_61, high_threshold_exceeded: true } }

        context 'when true' do
          let(:partner_partner_over_61) { true }

          it { is_expected.to be_valid }
        end

        context 'when false' do
          let(:partner_partner_over_61) { false }

          it { is_expected.to be_valid }
        end

        context 'when something other than true or false' do
          let(:partner_partner_over_61) { 'invalid' }

          before { subject.valid? }

          it { is_expected.not_to be_valid }
        end
      end
    end

    describe 'high threshold' do
      let(:hash) { { threshold_exceeded: true, partner_over_61: true, high_threshold_exceeded: high_threshold } }

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

  describe '#save' do
    let(:applicant) { build :applicant_with_all_details }
    let(:application) { create :application, applicant: applicant }
    subject(:form) { described_class.new(application) }

    subject do
      form.update_attributes(params)
      form.save
    end

    context 'when attributes are correct' do
      let(:params) { { threshold_exceeded: true, partner_over_61: true, high_threshold_exceeded: false } }

      it { is_expected.to be true }

      before do
        subject
        application.reload
      end

      it 'saves the parameters in the detail' do
        params.each do |key, value|
          expect(application.send(key)).to eql(value)
        end
      end
    end

    context 'when attributes are incorrect' do
      let(:params) { { threshold_exceeded: nil } }

      it { is_expected.to be false }
    end
  end
end
