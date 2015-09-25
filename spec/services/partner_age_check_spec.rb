require 'rails_helper'

RSpec.describe PartnerAgeCheck do
  let!(:application) { create :applicant_under_61 }
  let(:savings_investment) { Forms::SavingsInvestment.new(hash) }
  let(:hash) { { threshold_exceeded: true, over_61: partner_over_61, application_id: application.id } }
  let(:over_61_check) { described_class.new(savings_investment) }

  describe '#verify' do

    context 'when partner is over 61' do
      let(:partner_over_61) { true }

      it { expect(over_61_check.verify).to be true }
    end

    context 'when partner is under 61' do
      let(:partner_over_61) { false }

      it { expect(over_61_check.verify).to be true }
    end

    context 'when partner over 61 is assigned not boolean value' do
      let(:partner_over_61) { 'a string' }

      it { expect(over_61_check.verify).to be false }
    end
  end
end
