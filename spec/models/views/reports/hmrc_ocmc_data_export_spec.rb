# coding: utf-8

require 'rails_helper'

RSpec.describe Views::Reports::HmrcOcmcDataExport do
  subject(:ocmc_export) { described_class.new(from_date, to_date, office_id) }
  let(:from_date) { { day: date_from.day, month: date_from.month, year: date_from.year } }
  let(:to_date) { { day: date_to.day, month: date_to.month, year: date_to.year } }
  let(:office_id) { office.id }

  let(:office) { create(:office) }
  let(:date_from) { Date.parse('1/1/2021') }
  let(:date_to) { Date.parse('1/2/2021') }

  describe 'to_csv' do
    let(:application1) {
      create(:application, :processed_state, office: office, income_kind: {}, income: 89,
                                             detail: app1_detail, children_age_band: { one: 7, two: 8 }, income_period: 'last_month',
                                             income_min_threshold_exceeded: true, online_application: onlin_application1)
    }
    let(:application2) { create(:application, :waiting_for_evidence_state, office: office) }
    let(:application3) {
      create(:application, :waiting_for_part_payment_state, office: office,
                                                            detail: app3_detail, children_age_band: { one: 1, two: 1 }, income_period: 'average')
    }
    let(:application4) {
      create(:application, :deleted_state, office: office, detail: app2_detail,
                                           children_age_band: { one: 0, two: 1 }, income_max_threshold_exceeded: true, decision_date: Date.parse('2021-01-03'))
    }
    let(:application5) { create(:application, office: office) }
    let(:application6) { create(:application, :processed_state, office: office) }
    let(:application7) { create(:application, :processed_state) }

    let(:app1_detail) { create(:complete_detail, :legal_representative, calculation_scheme: 'post_ucd') }
    let(:app2_detail) { create(:complete_detail, :litigation_friend, calculation_scheme: 'pre_ucd') }
    let(:app3_detail) { create(:complete_detail, :applicant) }
    let(:benefit_overrides) { create(:benefit_override, application: application1, correct: benefits_override_correct) }
    let(:decision_overrides) { create(:decision_override, application: application1) }
    let(:benefits_override_correct) { true }
    let(:onlin_application1) { create(:online_application, created_at: Date.parse('1/11/2020')) }

    subject(:data) { ocmc_export.to_csv.split("\n") }

    before do
      Timecop.freeze(date_from + 1.day) { application1 }
      Timecop.freeze(date_from + 2.days) { application2 }
      Timecop.freeze(date_from + 3.days) { application3 }
      Timecop.freeze(date_from + 4.days) { application4 }
      Timecop.freeze(date_from + 5.days) { application5 }
      Timecop.freeze(date_from + 36.days) { application6 }
      Timecop.freeze(date_from + 6.days) { application7 }
      application1.applicant.update(partner_ni_number: 'SN789654C', married: true, ni_number: 'SN789654C')
      application3.applicant.update(partner_ni_number: 'SN789654C', partner_last_name: 'Jones', married: true, ni_number: 'SN789654C')
      application4.applicant.update(partner_ni_number: '', partner_last_name: 'Jones', married: true, ni_number: 'SN789654C')
    end

    it 'return 5 rows csv data' do
      expect(data.count).to be(5)
    end

    context 'data fields' do
      let(:application2) {
        create(:application, :waiting_for_evidence_state,
               office: office, income_kind: income_kind)
      }
      let(:evidence_check) { application2.evidence_check }
      let(:hmrc_check) {
        create(:hmrc_check, evidence_check: evidence_check,
                            created_at: 2.days.ago, income: nil, tax_credit: nil, request_params: date_range)
        create(:hmrc_check, evidence_check: evidence_check,
                            created_at: 1.day.ago, income: paye_income, tax_credit: tax_credit, request_params: date_range)
      }
      let(:income_kind) { {} }
      let(:tax_credit) { {} }
      let(:paye_income) { {} }
      let(:date_range) { { date_range: { from: "1/7/2022", to: "31/7/2022" } } }
      let(:hmrc_income_used) { 123.56 }
      let(:income_check_type) { 'hmrc' }

      before {
        evidence_check.update(hmrc_income_used: hmrc_income_used, income_check_type: income_check_type)
        hmrc_check
      }

      context 'paye income' do
        let(:paye_income) { [{ "taxablePay" => 120.04 }] }
        it "calculates correct value" do
          data_row = data[3]
          expect(data_row).to include('123.56')
        end
      end

      context 'paye and tax credit income' do
        it "calculates correct value" do
          data_row = data[3]
          expect(data_row).to include('123.56')
        end

        it 'displays formatted date range' do
          data_row = data[3]
          expect(data_row).to include('1/7/2022 - 31/7/2022')
        end

        context 'no fail from tax_credit' do
          let(:hmrc_income_used) { 120.04 }

          it "calculates correct value" do
            data_row = data[3]
            expect(data_row).to include('120.04')
          end

          context 'no date' do
            let(:date_range) { nil }
            it "calculates correct value" do
              data_row = data[3]
              expect(data_row).to include('120.04')
            end
          end
        end
      end

      context 'income_kind' do
        let(:income_kind) { { applicant: [:wage, :working_credit] } }
        it "calculates correct value" do
          data_row = data[3]
          expect(data_row).to include('Wages before tax and National Insurance are taken off,Working Tax Credit')
        end
      end

      context 'income_kind with partner' do
        let(:income_kind) { { applicant: [], partner: [:wage, :working_credit] } }
        it "calculates correct value" do
          data_row = data[3]
          expect(data_row).to include('Wages before tax and National Insurance are taken off,Working Tax Credit')
        end
      end

      context 'signed by values and partner data' do
        it {
          expect(data[4]).to include('legal_representative,true,false,post_ucd')
        }

        it {
          expect(data[1]).to include('litigation_friend,false,true,pre_ucd')
        }

        it {
          expect(data[2]).to include('applicant,true,true')
        }
      end
      context 'children age bands' do
        it {
          expect(data[4]).to include('89,N/A,under,true,N/A,last_month,1,7,8')
        }

        it {
          expect(data[1]).to include('500,N/A,over,false,2021-01-03 00:00:00,N/A,1,0,1')
        }

        it {
          expect(data[2]).to include('500,N/A,N/A,false,N/A,average,1,1,1')
        }
      end

      describe 'income processed' do
        let(:ec_income) { 0 }
        before { evidence_check.update(income: ec_income, completed_at: 1.day.ago) }
        let(:evidence_check) { application2.evidence_check }

        context 'hmrc check present' do
          let(:hmrc_check) {
            create(:hmrc_check, evidence_check: evidence_check, created_at: 2.days.ago, tax_credit: nil, request_params: date_range)
          }

          context 'income check type hmrc' do
            let(:ec_income) { 1536 }
            it "from evidence check" do
              reference = application2.reference
              data_row = data.find { |row| row.split(',')[1] == reference }
              expect(data_row).to include('HMRC NumberRule,Yes,N/A,Yes,N/A,1536')
            end
          end

          context 'income check type paper' do
            let(:income_check_type) { 'paper' }
            let(:ec_income) { 1515 }

            it "from evidence check" do
              reference = application2.reference
              data_row = data.find { |row| row.split(',')[1] == reference }
              expect(data_row).to include('JK123456A,2021-01-03,N/A,no,No,N/A,No')
              expect(data_row).to include('ManualAfterHMRC,Yes,N/A,Yes,N/A,1515')
            end
          end
        end

        context 'income check type paper and no hmrc check' do
          let(:income_check_type) { 'paper' }
          let(:ec_income) { 1578 }
          before { evidence_check2.update(income: ec_income, completed_at: 1.day.ago) }
          let(:evidence_check2) { create(:evidence_check, application: application1, income_check_type: 'paper') }

          it "from evidence check" do
            reference = application1.reference
            data_row = data.find { |row| row.split(',')[1] == reference }
            expect(data_row).to include('JK123456A,2021-01-02,2020-11-01 00:00:00,yes,No,N/A,No')
            expect(data_row).to include('ABC123,false,false,89,1578,under,true,N/A,last_month')
            expect(data_row).to include('Manual NumberRule,N/A,N/A,N/A,N/A,1578')
          end
        end
        context 'income loaded from application' do
          let(:income_check_type) { 'paper' }
          let(:income) { 1578 }
          before { application1.update(income: income) }

          it "from evidence check" do
            reference = application1.reference
            data_row = data.find { |row| row.split(',')[1] == reference }
            expect(data_row).to include('1578,N/A,legal_representative,true,false,post_ucd')
          end
        end
      end
    end

    describe 'outcomes' do
      let(:evidence_check) { create(:evidence_check, application: application1, outcome: 'part') }
      let(:part_payment) { create(:part_payment, application: application1, outcome: 'full') }

      context 'plain application savings passed' do
        it {
          decision_date = Date.parse('2025-04-22')
          application1.update(decision: 'full', decision_date:)
          application1.applicant.update(married: false)
          reference = application1.reference
          data_row = data.find { |row| row.split(',')[1] == reference }
          expect(data_row).to include('no,No,full,No,2021-01-02 00:00:00,N/A,N/A,N/A,N/A,0.0')
        }

        context 'decision none savings failed' do
          it {
            decision_date = Date.parse('2025-04-22')
            application1.update(decision: 'none', decision_date:)
            application1.saving.update(passed: false, over_66: true)
            reference = application1.reference
            data_row = data.find { |row| row.split(',')[1] == reference }
            expect(data_row).to include('yes,Yes,none,Yes,2021-01-02 00:00:00,N/A,N/A,N/A,N/A,0.0')
          }
        end

        context 'decision deleted' do
          it {
            decision_date = Date.parse('2025-04-22')
            application1.update(decision: 'full', decision_date:, state: 4)
            application1.saving.update(over_66: nil)
            reference = application1.reference
            data_row = data.find { |row| row.split(',')[1] == reference }
            expect(data_row).to include('yes,N/A,deleted,No,2021-01-02 00:00:00,N/A,N/A,N/A,N/A,0.0')
          }
        end

        context 'application not completed - no decision' do
          it {
            application1.update(decision: nil, decision_date: nil, state: 2)
            reference = application1.reference
            data_row = data.find { |row| row.split(',')[1] == reference }
            expect(data_row).to include('yes,No,N/A,No,2021-01-02 00:00:00,N/A,N/A,N/A,N/A,0.0')
          }
        end
      end

      context 'evidence check' do
        it {
          application1.update(decision: 'full')
          application1.applicant.update(married: false)
          evidence_check
          completed_date = Date.parse('2025-04-22')
          evidence_check.update(completed_at: completed_date, income_check_type: 'paper')

          reference = application1.reference
          data_row = data.find { |row| row.split(',')[1] == reference }
          expect(data_row).to include('no,No,full,No,2021-01-02 00:00:00,2025-04-22 00:00:00,N/A,part,N/A,0.0')
        }
      end

      context 'part payment check' do
        before {
          application1.update(decision: 'full')
          application1.applicant.update(married: false)
          evidence_check
          part_payment
          completed_date = Date.parse('2025-04-22')
          part_payment.update(completed_at: completed_date)
        }
        it {
          reference = application1.reference
          data_row = data.find { |row| row.split(',')[1] == reference }
          expect(data_row).to include('no,No,full,No,2021-01-02 00:00:00,N/A,2025-04-22 00:00:00,part,full,0.0')
          expect(data_row).to include('paper,no,N/A,yes,')
        }

        it {
          benefit_overrides
          decision_overrides

          reference = application1.reference
          data_row = data.find { |row| row.split(',')[1] == reference }
          # application source, decision granted, benefits granted, evidence checked
          expect(data_row).to include('paper,yes,Yes,yes,')
        }

        context 'with incorrect override' do
          let(:benefits_override_correct) { false }

          it {
            benefit_overrides
            decision_overrides

            reference = application1.reference
            data_row = data.find { |row| row.split(',')[1] == reference }
            # application source, decision granted, benefits granted, evidence checked
            expect(data_row).to include('paper,yes,No,yes,')
          }
        end
      end
    end
  end
end
