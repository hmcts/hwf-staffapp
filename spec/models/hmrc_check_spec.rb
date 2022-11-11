require 'rails_helper'

RSpec.describe HmrcCheck do
  describe 'serialized attributes' do
    subject(:hmrc_check) { described_class.new(evidence_check: evidence_check, user: user, request_params: date_range) }
    let(:evidence_check) { create(:evidence_check, application: application) }
    let(:application) { create(:application) }
    let(:date_range) { { date_range: { from: "2021-12-01", to: "2021-12-31" } } }
    let(:user) { create(:user) }

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

      describe 'getters' do
        before {
          hmrc_check.tax_credit = { child: ['child test'], work: ['work test'] }
          hmrc_check.save
        }
        context 'value present' do
          it { expect(hmrc_check.child_tax_credit).to eql ['child test'] }
          it { expect(hmrc_check.work_tax_credit).to eql ['work test'] }
        end

        context 'value missing' do
          before {
            hmrc_check.tax_credit = { child: nil, work: nil }
            hmrc_check.save
          }

          it { expect(hmrc_check.child_tax_credit).to be_nil }
          it { expect(hmrc_check.work_tax_credit).to be_nil }
        end

        context 'not initialized' do
          before {
            hmrc_check.tax_credit = nil
            hmrc_check.save
          }

          it { expect(hmrc_check.child_tax_credit).to be_nil }
          it { expect(hmrc_check.work_tax_credit).to be_nil }
        end
      end
    end

    context 'request_params' do
      before {
        hmrc_check.request_params = { date_range: { from: "2020-11-17", to: "2020-11-18" } }
        hmrc_check.save
      }

      it { expect(hmrc_check.request_params[:date_range][:from]).to eql("2020-11-17") }
      it { expect(hmrc_check.request_params[:date_range][:to]).to eql("2020-11-18") }
    end

    context 'hmrc income' do
      before {
        hmrc_check.income = [{ "taxablePay" => 1440.98, "employeePensionContribs" => { "paid" => 6.99 } }]
        hmrc_check.additional_income = 200
        hmrc_check.save
      }

      it { expect(hmrc_check.hmrc_income).to be 1447.97 }

      describe 'without data present' do
        it 'empty hash' do
          hmrc_check.update(income: [{ "taxablePay" => {} }])
          expect(hmrc_check.hmrc_income).to be 0
        end

        it 'no key present' do
          hmrc_check.update(income: [{ "taxablePay" => {} }])
          expect(hmrc_check.hmrc_income).to be 0
        end

        it 'income empty array' do
          hmrc_check.update(income: [])
          expect(hmrc_check.hmrc_income).to be 0
        end

        it 'income nil' do
          hmrc_check.update(income: nil)
          expect(hmrc_check.hmrc_income).to be 0
        end
      end

      context 'with tax credit' do
        before do
          hmrc_check.tax_credit = {
            child: [{ "payments" => [{ "amount" => 10.00, "startDate" => "1996-01-01", "endDate" => "1996-02-01", "frequency" => 1 }] }],
            work: [{ "payments" => [{ "amount" => 10.00, "startDate" => "1996-01-01", "endDate" => "1996-02-01", "frequency" => 1 }] }]
          }
          hmrc_check.save
        end
        it { expect(hmrc_check.hmrc_income.to_f).to be 1467.97 }
      end
    end

    context 'total income' do
      before {
        hmrc_check.income = [{ "taxablePay" => 12000.04 }]
        hmrc_check.additional_income = 200
        hmrc_check.save
      }

      it { expect(hmrc_check.total_income).to be 12200.04 }

      describe 'without hmrc_income' do
        it 'empty hash' do
          hmrc_check.update(income: [{ "taxablePay" => '' }])
          expect(hmrc_check.total_income).to be 200
        end
      end
    end

    context 'additional_income' do
      before { hmrc_check.additional_income = additional_income }
      subject(:valid?) { hmrc_check.valid? }

      context 'not a number' do
        let(:additional_income) { 'a' }

        it { is_expected.to be false }
      end

      context 'smaler then 0' do
        let(:additional_income) { '-1' }

        it { is_expected.to be false }
      end

      context 'greater then 0' do
        let(:additional_income) { '1' }

        it { is_expected.to be true }
      end

      context 'empty' do
        let(:additional_income) { nil }

        it { is_expected.to be true }
      end
    end

    context 'child_tax_credit_income' do
      before {
        child_income = [
          { "payProfCalcDate" => "2020-08-18",
            "totalEntitlement" => 18765.23,
            "childTaxCredit" => {
              "childCareAmount" => 930.98,
              "ctcChildAmount" => 730.49,
              "familyAmount" => 100.49,
              "babyAmount" => 100, "paidYTD" => 8976.34
            },
            "payments" => [
              { "startDate" => "1996-01-01", "endDate" => "1996-02-01", "frequency" => 1, "tcType" => "ICC", "amount" => 7634 },
              { "startDate" => "1996-03-01", "endDate" => "1996-04-01", "frequency" => 1, "tcType" => "ICC", "amount" => 5624 }
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
              { "startDate" => "1996-01-01", "endDate" => "1996-02-01", "frequency" => 1, "tcType" => "ICC", "amount" => 7034 },
              { "startDate" => "1996-03-01", "endDate" => "1996-04-01", "frequency" => 1, "tcType" => "ICC", "amount" => 5024 }
            ] }
        ]

        hmrc_check.tax_credit = { child: child_income, work: nil }
        hmrc_check.save
      }

      it { expect(hmrc_check.child_tax_credit_income).to eq 253.16 }
      it { expect(hmrc_check.work_tax_credit_income).to eq 0 }

    end

    context 'work_tax_credit_income' do
      before {
        work_income = [
          { payProfCalcDate: "1996-08-01",
            totalEntitlement: 18765.23,
            workingTaxCredit: {
              amount: 930.98,
              paidYTD: 8976.34
            },
            "payments" => [
              { "startDate" => "1996-01-01", "endDate" => "1996-02-01", "frequency" => 1, "tcType" => "ICC", "amount" => 8634 },
              { "startDate" => "1996-03-01", "endDate" => "1996-04-01", "frequency" => 1, "tcType" => "ICC", "amount" => 5624 }
            ] },
          { payProfCalcDate: "1996-08-01",
            totalEntitlement: 18765.23,
            workingTaxCredit: {
              amount: 930.98,
              paidYTD: 8976.34
            },
            "payments" => [
              { "startDate" => "1996-01-01", "endDate" => "1996-02-01", "frequency" => 1, "tcType" => "ICC", "amount" => 5034 },
              { "startDate" => "1996-03-01", "endDate" => "1996-04-01", "frequency" => 1, "tcType" => "ICC", "amount" => 5524 }
            ] }
        ]

        hmrc_check.tax_credit = { child: nil, work: work_income }
        hmrc_check.save
      }

      it { expect(hmrc_check.work_tax_credit_income).to eq 248.16 }
      it { expect(hmrc_check.child_tax_credit_income).to eq 0 }

      context 'no date range' do
        let(:date_range) { nil }
        it { expect(hmrc_check.work_tax_credit_income).to eq 0 }
        it { expect(hmrc_check.child_tax_credit_income).to eq 0 }
      end
    end

  end

  describe 'calculate_evidence_income!' do
    subject(:hmrc_check) { described_class.new(evidence_check: evidence_check, request_params: date_range) }
    let(:evidence_check) { create(:evidence_check, income: nil, application: application) }
    let(:application) { create(:single_applicant_under_61) }
    let(:date_range) { { date_range: { from: "2021-12-01", to: "2021-12-31" } } }

    context 'no income data' do
      before { hmrc_check.calculate_evidence_income! }
      it { expect(evidence_check.income).to be_nil }
    end

    context 'income present' do
      let(:income) { [{ "taxablePay" => 12000.04 }] }
      subject(:hmrc_check) { described_class.new(evidence_check: evidence_check, income: income, request_params: date_range) }

      before { hmrc_check.calculate_evidence_income! }
      it { expect(evidence_check.income).to eq(12000) }
      it { expect(evidence_check.outcome).to eq('none') }
      it { expect(evidence_check.amount_to_pay).to eq(310) }

      context 'full payment' do
        let(:income) { [{ "taxablePay" => 100.04 }] }
        it { expect(evidence_check.outcome).to eq('full') }
        it { expect(evidence_check.amount_to_pay).to eq(0) }
      end
    end

    context 'hmrc total income lower than aplication income' do
      let(:income) { [{ "taxablePay" => 1200.04 }] }
      let(:application) { create(:single_applicant_under_61, income: 15000) }
      let(:additional_income) { 0 }
      subject(:hmrc_check) { described_class.new(evidence_check: evidence_check, income: income, request_params: date_range, additional_income: additional_income) }

      before { hmrc_check.calculate_evidence_income! }
      it { expect(evidence_check.income).to eq(15000) }
      it { expect(evidence_check.outcome).to eq('none') }
      it { expect(evidence_check.amount_to_pay).to eq(310) }

      context 'full payment' do
        let(:income) { [{ "taxablePay" => 100.04 }] }
        let(:application) { create(:single_applicant_under_61, income: 120) }
        it { expect(evidence_check.outcome).to eq('full') }
        it { expect(evidence_check.amount_to_pay).to eq(0) }
      end

      context 'hmrc income + additional income higher than app income' do
        let(:income) { [{ "taxablePay" => 100.04 }] }
        let(:additional_income) { 21 }
        let(:application) { create(:single_applicant_under_61, income: 120) }

        it { expect(evidence_check.income).to eq(121) }
        it { expect(evidence_check.amount_to_pay).to eq(0) }
      end

      context 'hmrc income + additional income lower than app income' do
        let(:income) { [{ "taxablePay" => 100.04 }] }
        let(:additional_income) { 11 }
        let(:application) { create(:single_applicant_under_61, income: 120) }

        it { expect(evidence_check.income).to eq(120) }
        it { expect(evidence_check.amount_to_pay).to eq(0) }
      end
    end
  end
end
