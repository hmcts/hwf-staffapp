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

        hmrc_check.tax_credit = { child: child_income, work: nil, id: 123 }
        hmrc_check.save
      }

      it { expect(hmrc_check.child_tax_credit_income).to eq 240.6 }
      it { expect(hmrc_check.work_tax_credit_income).to eq 0 }
      it { expect(hmrc_check.tax_credit_id).to eq 123 }

      context 'hmrc income for partner' do
        before {
          hmrc_check.income = [{ "taxablePay" => 100.98, "employeePensionContribs" => { "paid" => 7.00 } }]
          hmrc_check.save
        }
        it { expect(hmrc_check.hmrc_income).to eq 348.58 }
        it { expect(hmrc_check.hmrc_income(123)).to eq 107.98 }
        it { expect(hmrc_check.hmrc_income(124)).to eq 348.58 }
      end

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

      context 'Tax credit entitlement date' do
        context 'all good' do
          before {
            allow(HmrcIncomeParser).to receive(:check_tax_credit_calculation_date).and_return true
          }
          it { expect(hmrc_check.tax_credit_entitlement_check).to be true }
        end

        context 'issue found' do
          before {
            allow(HmrcIncomeParser).to receive(:check_tax_credit_calculation_date).and_raise(HmrcTaxCreditEntitlement, "custom error")
          }

          it 'save the error to model' do
            hmrc_check.tax_credit_entitlement_check
            expect(hmrc_check.error_response).to eq("custom error")
          end

          it { expect(hmrc_check.tax_credit_entitlement_check).to be false }
        end
      end

    end

  end

end
