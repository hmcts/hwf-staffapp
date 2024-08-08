require 'rails_helper'

RSpec.describe HmrcCheckHelper do

  describe '#hmrc_income' do
    let(:evidence) {
      instance_double(EvidenceCheck,
                      applicant_hmrc_check: applicant_hmrc_check,
                      partner_hmrc_check: partner_hmrc_check)
    }
    let(:partner_hmrc_check) { instance_double(HmrcCheck, hmrc_income: partner_income) }
    let(:applicant_hmrc_check) { instance_double(HmrcCheck, hmrc_income: applicant_income) }

    context 'applicant and partner income' do
      let(:applicant_income) { 4 }
      let(:partner_income) { 6 }
      it { expect(helper.hmrc_income(evidence)).to eq "£10" }
    end

    context 'applicant only income' do
      let(:applicant_income) { 4 }
      let(:partner_income) { nil }
      it { expect(helper.hmrc_income(evidence)).to eq "£4" }
    end

    context 'partner only income' do
      let(:applicant_income) { nil }
      let(:partner_income) { 6 }
      it { expect(helper.hmrc_income(evidence)).to eq "£6" }
    end

    context 'no partner or applicant check' do
      let(:partner_hmrc_check) { nil }
      let(:applicant_hmrc_check) { nil }

      let(:applicant_income) { nil }
      let(:partner_income) { nil }
      it { expect(helper.hmrc_income(evidence)).to eq "£0" }
    end
  end
end
