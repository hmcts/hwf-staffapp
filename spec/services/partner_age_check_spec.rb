require 'rails_helper'

RSpec.describe PartnerAgeCheck do

  let(:savings_investment) { Applikation::Forms::SavingsInvestment.new(hash) }
  let(:hash) { { threshold_exceeded: true, partner_over_61: partner_over_61, application_id: application.id } }

  subject(:service) { described_class.new(savings_investment, application) }

  describe '#verify' do
    subject { service.verify }

    context 'when threshold has been exceeded' do
      context 'when applicant married' do
        let(:partner_over_61) { nil }

        context 'when applicant over 61' do
          let!(:application) { build_stubbed :married_applicant_over_61 }

          it { is_expected.to be true }
        end

        context 'when applicant under 61' do
          let!(:application) { build_stubbed :applicant_under_61 }

          context "when applicant's partner over 61" do
            let(:partner_over_61) { true }

            it { is_expected.to be true }
          end

          context "when applicant's partner under 61" do
            let(:partner_over_61) { false }

            it { is_expected.to be true }
          end

          context "when applicant's partner is set as invalid value" do
            let(:partner_over_61) { 'a string' }

            it { is_expected.to be false }
          end
        end
      end
    end
  end
end
