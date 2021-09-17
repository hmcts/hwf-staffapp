require 'rails_helper'

RSpec.describe HmrcCheck, type: :model do
  describe 'serialized attributes' do
    subject(:hmrc_check) { described_class.new(evidence_check: evidence_check) }
    let(:evidence_check) { create :evidence_check }

    context 'address' do
      before {
        hmrc_check.address = [
          {
            type: "NOMINATED",
            address: {
              line1: "24 Trinity Street"
            }
          }
        ]
        hmrc_check.save
      }

      it { expect(hmrc_check.address[0][:type]).to eql("NOMINATED") }
    end

    context 'employment' do
      before {
        hmrc_check.employment = [{ startDate: "2019-01-01", endDate: "2019-03-31" }]
        hmrc_check.save
      }

      it { expect(hmrc_check.employment[0][:startDate]).to eql("2019-01-01") }
    end

    context 'income' do
      before {
        hmrc_check.income = { taxReturns: [{ taxYear: "2018-19", summary: [{ totalIncome: 100.99 }] }] }
        hmrc_check.save
      }

      it { expect(hmrc_check.income[:taxReturns][0][:taxYear]).to eql("2018-19") }
    end

    context 'tax_credit' do
      before {
        hmrc_check.tax_credit = [{ id: 7210565654, awards: [{ payProfCalcDate: "2020-11-18" }] }]
        hmrc_check.save
      }

      it { expect(hmrc_check.tax_credit[0][:awards][0][:payProfCalcDate]).to eql("2020-11-18") }
    end
  end
end
