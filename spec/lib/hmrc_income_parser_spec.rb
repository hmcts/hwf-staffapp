require 'rails_helper'

RSpec.describe HmrcIncomeParser do
  describe 'paye' do
    let(:paye_hash) {
      [{ "grossEarningsForNics" => { "inPayPeriod1" => 12000.04, "inPayPeriod2" => 13000.38, "inPayPeriod3" => 14000.34, "inPayPeriod4" => 15000.69 } }]
    }

    it "returns income" do
      expect(described_class.paye(paye_hash)).to eq(54001.45)
    end
  end

  describe 'tax_credit' do
    let(:request_range) { { from: "2021-12-01", to: "2021-12-31" } }
    let(:tax_credit_hash) {
      [
        { "payProfCalcDate" => "2020-08-18",
          "totalEntitlement" => 1876523,
          "childTaxCredit" => {
            "childCareAmount" => 93098,
            "ctcChildAmount" => 73049,
            "familyAmount" => 10049,
            "babyAmount" => 100, "paidYTD" => 897634
          },
          "payments" => [
            { "startDate" => "1996-01-01", "endDate" => "1996-02-01", "frequency" => 1, "tcType" => "ICC", "amount" => 7634 },
            { "startDate" => "1996-03-01", "endDate" => "1996-04-01", "frequency" => 1, "tcType" => "ICC", "amount" => 5624 }
          ] },
        { "payProfCalcDate" => "2020-09-18",
          "totalEntitlement" => 1876523,
          "childTaxCredit" => {
            "childCareAmount" => 93098,
            "ctcChildAmount" => 73049,
            "familyAmount" => 10049,
            "babyAmount" => 100, "paidYTD" => 897634
          },
          "payments" => [
            { "startDate" => "1996-01-01", "endDate" => "1996-02-01", "frequency" => 1, "tcType" => "ICC", "amount" => 7034 },
            { "startDate" => "1996-03-01", "endDate" => "1996-04-01", "frequency" => 1, "tcType" => "ICC", "amount" => 5024 }
          ] }
      ]
    }

    it "returns income" do
      expect(described_class.tax_credit(tax_credit_hash, request_range).to_f).to eq(253.16)
    end

    describe 'frequency' do
      let(:tax_credit_hash) {
        [
          {
            "payments" => [
              { "startDate" => '2021-06-24', "endDate" => '2022-03-31', "frequency" => frequency, "tcType" => "ICC", "amount" => 17059 },
              { "startDate" => '2021-05-06', "endDate" => '2022-03-31', "frequency" => frequency, "tcType" => "ICC", "amount" => 17478 }
            ]
          }
        ]
      }

      context '1' do
        let(:frequency) { 1 }
        it { expect(described_class.tax_credit(tax_credit_hash, request_range).to_f).to eq(345.37) }
      end

      context '7' do
        let(:frequency) { 7 }
        it { expect(described_class.tax_credit(tax_credit_hash, request_range).to_f).to eq(1726.85) }
        context 'different frequency per payment' do
          let(:tax_credit_hash) {
            [
              {
                "payments" => [
                  { "startDate" => '2021-06-24', "endDate" => '2022-03-31', "frequency" => 7, "tcType" => "ICC", "amount" => 17059 },
                  { "startDate" => '2021-05-06', "endDate" => '2022-03-31', "frequency" => 14, "tcType" => "ICC", "amount" => 17478 }
                ]
              }
            ]
          }
          it { expect(described_class.tax_credit(tax_credit_hash, request_range).to_f).to eq(1377.29) }
        end
      end

      context '14' do
        let(:frequency) { 14 }
        it { expect(described_class.tax_credit(tax_credit_hash, request_range).to_f).to eq(865.52) }
      end

      context '28' do
        let(:frequency) { 28 }
        it { expect(described_class.tax_credit(tax_credit_hash, request_range).to_f).to eq(345.37) }
      end

    end
  end
end
