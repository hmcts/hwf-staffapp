require 'rails_helper'

RSpec.describe HmrcCheckHelper do

  describe '#hmrc_income' do
    let(:evidence) {
      instance_double(EvidenceCheck, hmrc_income: hmrc_income)
    }

    let(:hmrc_income) { 10 }
    it { expect(helper.hmrc_income(evidence)).to eq "£10" }

    context 'no income' do
      let(:hmrc_income) { 0 }
      it { expect(helper.hmrc_income(evidence)).to eq "£0" }
    end
  end
end
