require 'rails_helper'

RSpec.describe PartnerAgeCheck do

  let(:savings_investment) { Forms::SavingsInvestment.new(hash) }
  let(:hash) { { threshold_exceeded: true, partner_over_61: partner_over_61, application_id: application.id } }
  let(:partner_over_61_check) { described_class.new(savings_investment) }

  describe '#verify' do
    context 'when threshold has been exceeded' do
      context 'when applicant married' do
        let(:partner_over_61) { nil }

        context 'when applicant over 61' do
          let!(:application) { create :married_applicant_over_61 }

          it { expect(partner_over_61_check.verify).to be true }

          xcontext 'high_threshold_exceeded' do
            before { partner_over_61_check.verify }

            it 'set to false' do
              expect(application.high_threshold_exceeded).to be_false
            end
          end
        end

        context 'when applicant under 61' do
          let!(:application) { create :applicant_under_61 }

          context "when applicant's partner over 61" do
            let(:partner_over_61) { true }

            it { expect(partner_over_61_check.verify).to be true }
          end

          context "when applicant's partner under 61" do
            let(:partner_over_61) { false }

            it { expect(partner_over_61_check.verify).to be true }
          end

          context "when applicant's partner is set as invalid value" do
            let(:partner_over_61) { 'a string' }

            it { expect(partner_over_61_check.verify).to be false }
          end
        end
      end

      context 'when applicant single'
    end
  end
end
