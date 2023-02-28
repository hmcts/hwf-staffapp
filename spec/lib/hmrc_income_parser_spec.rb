require 'rails_helper'

RSpec.describe HmrcIncomeParser do
  describe 'paye' do
    let(:paye_hash) {
      [{ "taxablePay" => 144.98, "employeePensionContribs" => { "paidYTD" => 737.17, "notPaidYTD" => 0, "paid" => 6.99, "notPaid" => 0 },
         "grossEarningsForNics" => { "inPayPeriod1" => 12000.04 } }]
    }

    it "returns income" do
      expect(described_class.paye(paye_hash)).to eq(151.97)
    end

    context 'missing pension' do
      let(:paye_hash) {
        [{ "taxablePay" => 144.98 }]
      }

      it "returns income" do
        expect(described_class.paye(paye_hash)).to eq(144.98)
      end
    end

    context 'multiple incomes' do
      let(:paye_hash) {
        [{ "taxablePay" => 144.98, "employeePensionContribs" => { "paid" => 6.99 } },
         { "taxablePay" => 144.98, "employeePensionContribs" => { "paid" => 6.99 } }]
      }

      it "returns income" do
        expect(described_class.paye(paye_hash)).to eq(303.94)
      end
    end
  end

  describe 'child tax_credit' do
    let(:request_range) { { from: "2021-12-01", to: "2021-12-31" } }
    let(:amount_one) { 7634 }
    let(:amount_two) { 5624 }
    let(:total_entitlement) { 7432.23 }
    let(:child_care_amount) { 1310.41 }
    let(:tax_credit_hash) {
      [
        { "payProfCalcDate" => "2020-08-18",
          "totalEntitlement" => total_entitlement,
          "childTaxCredit" => {
            "childCareAmount" => child_care_amount,
            "ctcChildAmount" => 73049,
            "familyAmount" => 10049,
            "babyAmount" => 100, "paidYTD" => 897634
          },
          "payments" => [
            { "startDate" => "1996-01-01", "endDate" => "1996-02-01", "frequency" => 1, "tcType" => "ICC", "amount" => amount_one },
            { "startDate" => "1996-03-01", "endDate" => "1996-04-01", "frequency" => 1, "tcType" => "ICC", "amount" => amount_two }
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
      expect(described_class.tax_credit(tax_credit_hash, request_range).to_f).to eq(223.8)
    end

    context 'totalEntitlement is 0' do
      let(:request_range) { { from: "2022-09-01", to: "2022-09-30" } }
      let(:total_entitlement) { 0 }

      it { expect(described_class.tax_credit(tax_credit_hash, request_range).to_f).to eq(247.18) }
    end

    context 'childCareAmount is 0' do
      let(:request_range) { { from: "2022-09-01", to: "2022-09-30" } }
      let(:child_care_amount) { 0 }

      it { expect(described_class.tax_credit(tax_credit_hash, request_range).to_f).to eq(247.18) }
    end

    context 'childCareAmount is nil' do
      let(:request_range) { { from: "2022-09-01", to: "2022-09-30" } }
      let(:child_care_amount) { nil }

      it { expect(described_class.tax_credit(tax_credit_hash, request_range).to_f).to eq(247.18) }
    end

    context 'totalEntitlement is nil' do
      let(:request_range) { { from: "2022-09-01", to: "2022-09-30" } }
      let(:total_entitlement) { nil }

      it { expect(described_class.tax_credit(tax_credit_hash, request_range).to_f).to eq(247.18) }
    end

    describe 'working tax' do
      let(:tax_credit_hash) {
        [
          { "payProfCalcDate" => "2020-09-18",
            "totalEntitlement" => 1876523,
            "workingTaxCredit" => {
              "amount" => 73049,
              "paidYTD" => 897634,
              "childCareAmount" => 93098
            },
            "payments" => [
              { "startDate" => '2021-06-24', "endDate" => '2022-03-31', "frequency" => frequency, "tcType" => "ICC", "amount" => 17059 },
              { "startDate" => '2021-05-06', "endDate" => '2022-03-31', "frequency" => frequency, "tcType" => "ICC", "amount" => 17478 }
            ] }
        ]
      }

      context '1' do
        let(:frequency) { 1 }
        it { expect(described_class.tax_credit(tax_credit_hash, request_range).to_f).to eq(345.37) }
      end
    end

    context 'decimal point present' do
      let(:amount_one) { 76.34 }
      let(:amount_two) { 5624 }
      it { expect(described_class.tax_credit(tax_credit_hash, request_range).to_f).to eq(223.8) }
    end

    context 'cost of living credits' do
      let(:tax_credit_hash) {
        [
          { "payProfCalcDate" => "2020-09-18",
            "totalEntitlement" => 1876523,
            "childTaxCredit" => {
              "childCareAmount" => 93098,
              "ctcChildAmount" => 73049,
              "familyAmount" => 10049,
              "babyAmount" => 100, "paidYTD" => 897634
            },
            "payments" => [
              { "startDate" => "2022-04-19", "endDate" => "2023-04-04", "frequency" => 1, "tcType" => "ICC", "amount" => 65.27 },
              { "startDate" => "2022-09-01", "endDate" => "2022-09-10", "frequency" => 1, "tcType" => "ICC", "amount" => 326.00 }
            ] }
        ]
      }

      context 'September' do
        let(:request_range) { { from: "2022-09-01", to: "2022-09-30" } }
        it { expect(described_class.tax_credit(tax_credit_hash, request_range).to_f).to eq(62.03) }
      end

      context 'November' do
        let(:tax_credit_hash) {
          [
            { "payProfCalcDate" => "2020-09-18",
              "totalEntitlement" => 1876523,
              "childTaxCredit" => {
                "childCareAmount" => 93098,
                "ctcChildAmount" => 73049,
                "familyAmount" => 10049,
                "babyAmount" => 100, "paidYTD" => 897634
              },
              "payments" => [
                { "startDate" => "2022-04-19", "endDate" => "2023-04-04", "frequency" => 1, "tcType" => "ICC", "amount" => 65.27 },
                { "startDate" => "2022-11-01", "endDate" => "2022-11-20", "frequency" => 1, "tcType" => "ICC", "amount" => 324.00 }
              ] }
          ]
        }

        let(:request_range) { { from: "2022-11-01", to: "2022-11-30" } }
        it { expect(described_class.tax_credit(tax_credit_hash, request_range).to_f).to eq(62.03) }
      end

    end

    describe 'frequency' do
      let(:tax_credit_hash) {
        [
          { "payProfCalcDate" => "2020-09-18",
            "totalEntitlement" => 1876523,
            "childTaxCredit" => {
              "childCareAmount" => 93098,
              "ctcChildAmount" => 73049,
              "familyAmount" => 10049,
              "babyAmount" => 100, "paidYTD" => 897634
            },
            "payments" => [
              { "startDate" => '2021-06-24', "endDate" => '2022-03-31', "frequency" => frequency, "tcType" => "ICC", "amount" => 17059 },
              { "startDate" => '2021-05-06', "endDate" => '2022-03-31', "frequency" => frequency, "tcType" => "ICC", "amount" => 17478 }
            ] }
        ]
      }

      context '1' do
        let(:frequency) { 1 }
        it { expect(described_class.tax_credit(tax_credit_hash, request_range).to_f).to eq(328.24) }
      end

      context '0' do
        let(:frequency) { 0 }
        it { expect(described_class.tax_credit(tax_credit_hash, request_range).to_f).to eq(0.0) }
      end

      context '7' do
        let(:frequency) { 7 }
        it { expect(described_class.tax_credit(tax_credit_hash, request_range).to_f).to eq(1641.18) }

        context 'different frequency per payment' do
          let(:tax_credit_hash) {
            [
              { "payProfCalcDate" => "2020-09-18",
                "totalEntitlement" => 1876523,
                "childTaxCredit" => {
                  "childCareAmount" => 93098,
                  "ctcChildAmount" => 73049,
                  "familyAmount" => 10049,
                  "babyAmount" => 100, "paidYTD" => 897634
                },
                "payments" => [
                  { "startDate" => '2021-06-24', "endDate" => '2022-03-31', "frequency" => 7, "tcType" => "ICC", "amount" => 17059 },
                  { "startDate" => '2021-05-06', "endDate" => '2022-03-31', "frequency" => 14, "tcType" => "ICC", "amount" => 17478 }
                ] }
            ]
          }
          it { expect(described_class.tax_credit(tax_credit_hash, request_range).to_f).to eq(1308.96) }
        end
      end

      context '14' do
        let(:frequency) { 14 }
        it { expect(described_class.tax_credit(tax_credit_hash, request_range).to_f).to eq(822.58) }
      end

      context '28' do
        let(:frequency) { 28 }
        it { expect(described_class.tax_credit(tax_credit_hash, request_range).to_f).to eq(328.24) }
      end

    end
  end
end
