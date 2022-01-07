require 'rails_helper'

RSpec.describe HmrcIncomeParser do
  describe 'paye' do
    let(:paye_hash) {
      [{ "grossEarningsForNics" => { "inPayPeriod1" => 12000.04, "inPayPeriod2" => 13000.38, "inPayPeriod3" => 14000.34, "inPayPeriod4" => 15000.69 } }]
    }

    it "returns income" do
      expect(HmrcIncomeParser.paye(paye_hash)).to eq(54001.45)
    end
  end

  describe 'tax_credit' do
    let(:tax_credit_hash) {
        [
          { "payProfCalcDate" => "2020-08-18",
            "totalEntitlement" => 18765.23,
            "childTaxCredit" => {
              "childCareAmount" => 930.98,
              "ctcChildAmount" => 730.49,
              "familyAmount" => 100.49,
              "babyAmount" => 100, "paidYTD" => 8976.34
            },
            "payments" => [
              { "startDate" => "1996-01-01", "endDate" => "1996-02-01", "frequency" => 7, "tcType" => "ICC", "amount" => 76.34 },
              { "startDate" => "1996-03-01", "endDate" => "1996-04-01", "frequency" => 7, "tcType" => "ICC", "amount" => 56.24 }
            ] },
          { "payProfCalcDate" => "2020-09-18",
            "totalEntitlement" => 18765.23,
            "childTaxCredit" => {
              "childCareAmount" => 930.98,
              "ctcChildAmount" => 730.49,
              "familyAmount" => 100.49,
              "babyAmount" => 100, "paidYTD" => 8976.34
            },
            "payments" => [
              { "startDate" => "1996-01-01", "endDate" => "1996-02-01", "frequency" => 7, "tcType" => "ICC", "amount" => 70.34 },
              { "startDate" => "1996-03-01", "endDate" => "1996-04-01", "frequency" => 7, "tcType" => "ICC", "amount" => 50.24 }
            ] }
        ]
    }

    it "returns income" do
      expect(HmrcIncomeParser.tax_credit(tax_credit_hash)).to eq(253.16)
    end
  end
end
