# coding: utf-8

require 'rails_helper'
require 'test_prof/recipes/rspec/before_all'
require 'test_prof/recipes/rspec/let_it_be'

require 'csv'

RSpec.describe Views::Reports::HmrcOcmcDataExport do
  subject(:ocmc_export) { described_class.new(from_date, to_date, office_id) }
  let(:from_date) { { day: date_from.day, month: date_from.month, year: date_from.year } }
  let(:to_date) { { day: date_to.day, month: date_to.month, year: date_to.year } }
  let(:office_id) { office.id }

  let_it_be(:office) { create(:office) }
  let_it_be(:digital_office) { create(:office, name: 'Digital') }
  let_it_be(:hmcts_hq_office) { create(:office, name: 'HMCTS HQ Team') }
  let_it_be(:bristol_office) { create(:office, name: 'Bristol') }
  let_it_be(:cardiff_office) { create(:office, name: 'Cardiff') }
  let(:date_from) { Date.parse('1/1/2021') }
  let(:date_to) { Date.parse('1/2/2021') }

  describe 'excluded offices' do
    context 'when office is Digital and HMCTS one' do
      before do
        travel_to(date_from + 1.day) do
          create(:application, :processed_state, office: digital_office)
          create(:application, :processed_state, office: hmcts_hq_office)
        end
      end

      it 'returns no results' do
        expect(ocmc_export.to_csv).to eq('no results')
      end
    end

    context 'when office is Bristol' do
      let(:office_id) { bristol_office.id }

      before do
        travel_to(date_from + 1.day) do
          create(:application, :processed_state, office: bristol_office, reference: 'BR123456A')
        end
      end

      it 'returns no results' do
        expect(ocmc_export.to_csv).not_to eq('no results')
        expect(ocmc_export.to_csv).to include('BR123456A')
      end
    end
  end

  describe 'to_csv' do
    let_it_be(:app1_detail) {
      create(:complete_detail, :legal_representative, calculation_scheme: 'post_ucd', date_received: Date.parse('2021-01-02'))
    }
    let_it_be(:app2_detail) {
      create(:complete_detail, :litigation_friend, calculation_scheme: 'pre_ucd', date_received: Date.parse('2021-01-05'))
    }
    let_it_be(:app3_detail) {
      create(:complete_detail, :applicant, date_received: Date.parse('2021-01-04'))
    }
    let_it_be(:onlin_application1) { create(:online_application, created_at: Date.parse('1/11/2020')) }

    let_it_be(:application1) {
      travel_to(Date.parse('1/1/2021') + 1.day) do
        create(:application, :processed_state, office: office, income_kind: {}, income: 89,
                                               reference: 'PA21-000001',
                                               detail: app1_detail, children_age_band: { one: 7, two: 8 }, income_period: 'last_month',
                                               income_min_threshold_exceeded: true, online_application: onlin_application1)
      end
    }
    let_it_be(:application3) {
      travel_to(Date.parse('1/1/2021') + 3.days) do
        create(:application, :waiting_for_part_payment_state, office: office,
                                                              reference: 'PA21-000003',
                                                              detail: app3_detail, children_age_band: { one: 1, two: 1 }, income_period: 'average')
      end
    }
    let_it_be(:application4) {
      travel_to(Date.parse('1/1/2021') + 4.days) do
        create(:application, :deleted_state, office: office, detail: app2_detail,
                                             reference: 'PA21-000004',
                                             children_age_band: { one: 0, two: 1 }, income_max_threshold_exceeded: true, decision_date: Date.parse('2021-01-03'))
      end
    }
    let_it_be(:application5) {
      travel_to(Date.parse('1/1/2021') + 5.days) { create(:application, :with_reference, office: office, reference: 'PA21-000005') }
    }
    let_it_be(:application6) {
      travel_to(Date.parse('1/1/2021') + 36.days) { create(:application, :processed_state, office: office, reference: 'PA21-000006') }
    }
    let_it_be(:application7) {
      travel_to(Date.parse('1/1/2021') + 6.days) { create(:application, :processed_state, reference: 'PA21-000007') }
    }

    let(:application2) {
      app = create(:application, :with_reference, office: office, state: :waiting_for_evidence)
      create(:evidence_check, application: app)
      app
    }
    let(:benefit_overrides) { create(:benefit_override, application: application1, correct: benefits_override_correct) }
    let(:decision_overrides) { create(:decision_override, application: application1) }
    let(:benefits_override_correct) { true }

    subject(:data) { ocmc_export.to_csv.split("\n") }

    before do
      travel_to(date_from + 2.days) { application2 }
      application1.reload.applicant.update(partner_ni_number: 'SN789654C', married: true, ni_number: 'SN789654C')
      application3.reload.applicant.update(partner_ni_number: 'SN789654C', partner_last_name: 'Jones', married: true, ni_number: 'SN789654C')
      application4.reload.applicant.update(partner_ni_number: '', partner_last_name: 'Jones', married: true, ni_number: 'SN789654C')
    end

    it 'return 6 rows csv data' do
      expect(data.count).to be(6)
    end

    describe 'id column' do
      it 'includes Id in the header' do
        expect(data[0]).to include('Id')
      end

      it 'contains the application id' do
        reference = application1.reference
        data_row = data.find { |row| row.include?(reference) }
        expect(data_row).to include(application1.id.to_s)
      end
    end

    describe 'status column' do
      it 'includes Status in the header' do
        expect(data[0]).to include('Status')
      end

      it 'returns Completed for processed application' do
        reference = application1.reference
        data_row = data.find { |row| row.split(',')[3] == reference }
        expect(data_row).to include('Completed')
      end

      it 'returns Waiting for evidence for waiting_for_evidence application' do
        reference = application2.reference
        data_row = data.find { |row| row.split(',')[3] == reference }
        expect(data_row).to include('Waiting for evidence')
      end

      it 'returns Waiting for part-payment for waiting_for_part_payment application' do
        reference = application3.reference
        data_row = data.find { |row| row.split(',')[3] == reference }
        expect(data_row).to include('Waiting for part-payment')
      end

      it 'returns Deleted for deleted application' do
        reference = application4.reference
        data_row = data.find { |row| row.split(',')[3] == reference }
        expect(data_row).to include('Deleted')
      end

      it 'returns Unprocessed for created application with date_received' do
        reference = application5.reference
        data_row = data.find { |row| row.split(',')[3] == reference }
        expect(data_row).to include('Unprocessed')
      end

      context 'created application without date_received' do
        let(:application_no_date) { create(:application, :with_reference, office: office) }

        before do
          travel_to(date_from + 5.days) { application_no_date }
          application_no_date.detail.update!(date_received: nil)
        end

        it 'excludes the application' do
          reference = application_no_date.reference
          data_row = data.find { |row| row.split(',')[3] == reference }
          expect(data_row).to be_nil
        end
      end

      context 'created application without refund' do
        let(:application_no_refund) { create(:application, :with_reference, office: office) }

        before do
          travel_to(date_from + 5.days) { application_no_refund }
          application_no_refund.detail.update!(refund: nil)
        end

        it 'excludes the application' do
          reference = application_no_refund.reference
          data_row = data.find { |row| row.split(',')[3] == reference }
          expect(data_row).to be_nil
        end
      end
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
          data_row = data[4]
          expect(data_row).to include('123.56')
        end
      end

      context 'paye and tax credit income' do
        it "calculates correct value" do
          data_row = data[4]
          expect(data_row).to include('123.56')
        end

        it 'displays formatted date range' do
          data_row = data[4]
          expect(data_row).to include('1/7/2022 - 31/7/2022')
        end

        context 'no fail from tax_credit' do
          let(:hmrc_income_used) { 120.04 }

          it "calculates correct value" do
            data_row = data[4]
            expect(data_row).to include('120.04')
          end

          context 'no date' do
            let(:date_range) { nil }
            it "calculates correct value" do
              data_row = data[4]
              expect(data_row).to include('120.04')
            end
          end
        end
      end

      context 'income_kind' do
        let(:income_kind) { { applicant: [:wage, :working_credit] } }
        it "calculates correct value" do
          data_row = data[4]
          expect(data_row).to include('Wages before tax and National Insurance are taken off,Working Tax Credit')
        end
      end

      context 'income_kind with partner' do
        let(:income_kind) { { applicant: [], partner: [:wage, :working_credit] } }
        it "calculates correct value" do
          data_row = data[4]
          expect(data_row).to include('Wages before tax and National Insurance are taken off,Working Tax Credit')
        end
      end

      context 'signed by values and partner data' do
        it {
          expect(data[5]).to include('legal_representative,true,false,post_ucd')
        }

        it {
          expect(data[2]).to include('litigation_friend,false,true,pre_ucd')
        }

        it {
          expect(data[3]).to include('applicant,true,true')
        }
      end
      context 'children age bands' do
        it {
          expect(data[5]).to include('89,N/A,true,N/A,last_month,1,7,8')
        }

        it {
          expect(data[2]).to include('500,N/A,false,2021-01-03 00:00:00,N/A,1,0,1')
        }

        it {
          expect(data[3]).to include('500,N/A,false,N/A,average,1,1,1')
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
              data_row = data.find { |row| row.split(',')[3] == reference }
              expect(data_row).to include('HMRC NumberRule,Yes,N/A,Yes,N/A,1536')
            end
          end

          context 'income check type paper' do
            let(:income_check_type) { 'paper' }
            let(:ec_income) { 1515 }

            it "from evidence check" do
              reference = application2.reference
              data_row = data.find { |row| row.split(',')[3] == reference }
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
            data_row = data.find { |row| row.split(',')[3] == reference }
            expect(data_row).to include('JK123456A,2021-01-02,2020-11-01 00:00:00,yes,No,N/A,No')
            expect(data_row).to include('ABC123,false,false,0.0,89,1578,true,N/A,last_month')
            expect(data_row).to include('Manual NumberRule,N/A,N/A,N/A,N/A,1578')
          end
        end
        context 'income loaded from application' do
          let(:income_check_type) { 'paper' }
          let(:income) { 1578 }
          before { application1.update(income: income) }

          it "from evidence check" do
            reference = application1.reference
            data_row = data.find { |row| row.split(',')[3] == reference }
            expect(data_row).to include('1578,N/A,legal_representative,true,false,post_ucd')
          end
        end

        context 'low_income check_type' do
          let(:low_income_evidence_check) {
            create(:evidence_check, application: application1,
                                    check_type: 'low_income',
                                    income_check_type: ec_income_check_type,
                                    completed_at: 1.day.ago)
          }

          context 'with paper income_check_type and no HMRC check' do
            let(:ec_income_check_type) { 'paper' }

            it 'returns Manual LowIncome evidence check type' do
              low_income_evidence_check
              reference = application1.reference
              data_row = data.find { |row| row.split(',')[3] == reference }
              expect(data_row).to include('Manual LowIncome')
            end
          end

          context 'with hmrc income_check_type' do
            let(:ec_income_check_type) { 'hmrc' }

            it 'returns HMRC LowIncome evidence check type' do
              low_income_evidence_check
              reference = application1.reference
              data_row = data.find { |row| row.split(',')[3] == reference }
              expect(data_row).to include('HMRC LowIncome')
            end
          end

          context 'with paper income_check_type and HMRC check present' do
            let(:ec_income_check_type) { 'paper' }

            it 'returns ManualAfterHMRC evidence check type' do
              low_income_evidence_check
              create(:hmrc_check, evidence_check: low_income_evidence_check,
                                  created_at: 1.day.ago, request_params: date_range)
              reference = application1.reference
              data_row = data.find { |row| row.split(',')[3] == reference }
              expect(data_row).to include('ManualAfterHMRC')
            end
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
          data_row = data.find { |row| row.split(',')[3] == reference }
          expect(data_row).to include('no,No,full,No,2021-01-02 00:00:00,N/A,N/A,N/A,N/A')
        }

        context 'nil amount_to_pay defaults to zero' do
          it {
            decision_date = Date.parse('2025-04-22')
            application1.update(decision: 'full', decision_date:, amount_to_pay: nil)
            application1.applicant.update(married: false)
            reference = application1.reference
            data_row = data.find { |row| row.split(',')[3] == reference }
            expect(data_row).to include('false,0.0,89')
          }
        end

        context 'decision none savings failed' do
          it {
            decision_date = Date.parse('2025-04-22')
            application1.update(decision: 'none', decision_date:, amount_to_pay: 75.5)
            application1.saving.update(passed: false, over_66: true)
            reference = application1.reference
            data_row = data.find { |row| row.split(',')[3] == reference }
            expect(data_row).to include('yes,Yes,none,Yes,2021-01-02 00:00:00,N/A,N/A,N/A,N/A')
            expect(data_row).to include('false,75.5,89')
          }
        end

        context 'decision deleted' do
          it {
            decision_date = Date.parse('2025-04-22')
            application1.update(decision: 'full', decision_date:, state: 4)
            application1.saving.update(over_66: nil)
            reference = application1.reference
            data_row = data.find { |row| row.split(',')[3] == reference }
            expect(data_row).to include('yes,N/A,deleted,No,2021-01-02 00:00:00,N/A,N/A,N/A,N/A')
          }
        end

        context 'application not completed - no decision' do
          it {
            application1.update(decision: nil, decision_date: nil, state: 2)
            reference = application1.reference
            data_row = data.find { |row| row.split(',')[3] == reference }
            expect(data_row).to include('yes,No,N/A,No,2021-01-02 00:00:00,N/A,N/A,N/A,N/A')
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
          data_row = data.find { |row| row.split(',')[3] == reference }
          expect(data_row).to include('no,No,full,No,2021-01-02 00:00:00,2025-04-22 00:00:00,N/A,part,N/A')
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
          data_row = data.find { |row| row.split(',')[3] == reference }
          expect(data_row).to include('no,No,full,No,2021-01-02 00:00:00,N/A,2025-04-22 00:00:00,part,full')
          expect(data_row).to include('paper,no,N/A,yes,')
        }

        it {
          benefit_overrides
          decision_overrides

          reference = application1.reference
          data_row = data.find { |row| row.split(',')[3] == reference }
          # application source, decision granted, benefits granted, evidence checked
          expect(data_row).to include('paper,yes,Yes,yes,')
        }

        context 'with incorrect override' do
          let(:benefits_override_correct) { false }

          it {
            benefit_overrides
            decision_overrides

            reference = application1.reference
            data_row = data.find { |row| row.split(',')[3] == reference }
            # application source, decision granted, benefits granted, evidence checked
            expect(data_row).to include('paper,yes,No,yes,')
          }
        end
      end
    end
  end

  describe 'CSV header shape' do
    let(:expected_headers) do
      ['Office', 'Id', 'Status', 'HwF reference number', 'Created at', 'Fee',
       'Jurisdiction', 'Application type', 'Form', 'Refund', 'Emergency',
       'Applicant pays estimate', 'Pre evidence income', 'Post evidence income',
       'Low income declared', 'Decision date', 'Income period', 'Children',
       'Age band under 14', 'Age band 14+', 'Applicant pays',
       'Departmental cost estimate', 'Departmental cost', 'Source', 'Granted?',
       'Benefits granted?', 'Evidence checked?', 'Capital band',
       'Saving and Investments', 'Case number', 'Date received',
       'Date submitted online', 'Married', 'Pension age', 'Decision',
       'Failed on savings', 'Application processed date',
       'Manual evidence processed date', 'Processed date', 'EV check outcome',
       'PP outcome', 'Declared income sources', 'DB evidence check type',
       'DB income check type', 'HMRC total income', 'Evidence check type',
       'HMRC response?', 'HMRC errors', 'Complete processing?',
       'Additional income', 'Income processed', 'HMRC request date range',
       'Statement signed by', 'Partner NI entered', 'Partner name entered',
       'HwF Scheme', 'Deletion Reason', 'Reason Description']
    end

    before { travel_to(date_from + 1.day) { create(:application, :processed_state, office: office) } }

    it 'has the 58 expected columns in the expected order' do
      csv = CSV.parse(ocmc_export.to_csv, headers: true)

      expect(csv.headers).to eq(expected_headers)
    end
  end

  describe 'all_offices: true' do
    subject(:ocmc_export) { described_class.new(from_date, to_date, office_id, all_offices: true) }

    let(:office_id) { bristol_office.id }

    before do
      travel_to(date_from + 1.day) do
        create(:application, :processed_state, office: bristol_office, reference: 'BR111111A')
        create(:application, :processed_state, office: cardiff_office, reference: 'CD222222B')
        create(:application, :processed_state, office: digital_office, reference: 'DG333333C')
        create(:application, :processed_state, office: hmcts_hq_office, reference: 'HQ444444D')
      end
    end

    it 'includes both eligible offices and excludes Digital / HMCTS HQ Team' do
      offices = CSV.parse(ocmc_export.to_csv, headers: true)['Office']

      aggregate_failures do
        expect(offices).to include('Bristol', 'Cardiff')
        expect(offices).not_to include('Digital', 'HMCTS HQ Team')
      end
    end
  end

  describe 'golden row (fully populated application)' do
    let(:office_id) { cardiff_office.id }
    let(:jurisdiction) { create(:jurisdiction, name: 'County Court') }
    let(:online_application) { create(:online_application, created_at: Date.parse('1/11/2020')) }
    let(:detail) {
      create(:complete_detail, :legal_representative,
             jurisdiction: jurisdiction,
             fee: 410,
             form_name: 'N1A',
             case_number: 'GOLD0001',
             date_received: Date.parse('1/1/2021'),
             refund: false,
             emergency_reason: 'urgent injunction',
             calculation_scheme: 'post_ucd')
    }
    let(:application) {
      travel_to(date_from + 1.day) do
        app = create(:application, :processed_state,
                     office: cardiff_office,
                     detail: detail,
                     online_application: online_application,
                     reference: 'GOLD0001',
                     application_type: 'income',
                     amount_to_pay: 50,
                     income: 89,
                     income_period: 'last_month',
                     income_kind: { applicant: [:wage] },
                     children: 2,
                     children_age_band: { one: 1, two: 1 },
                     decision: 'full',
                     decision_date: Date.parse('2/1/2021'),
                     decision_type: 'evidence_check',
                     completed_at: Date.parse('3/1/2021'))
        app.applicant.update!(married: true, ni_number: 'AB123456C',
                              partner_ni_number: 'CD789012E', partner_last_name: 'Smith')
        app.saving.update!(amount: 1500, min_threshold_exceeded: false,
                           max_threshold_exceeded: false, passed: true, over_66: false)
        app
      end
    }
    let(:evidence_check) {
      create(:evidence_check, application: application,
                              check_type: 'random', income_check_type: 'hmrc',
                              income: 1500, hmrc_income_used: 1500.0,
                              outcome: 'full', completed_at: Date.parse('2/1/2021'))
    }
    let(:hmrc_check) {
      create(:hmrc_check, evidence_check: evidence_check,
                          created_at: Date.parse('2/1/2021'),
                          additional_income: 50, error_response: nil,
                          request_params: { date_range: { from: '1/1/2021', to: '31/1/2021' } })
    }
    let(:part_payment) {
      create(:part_payment, application: application,
                            outcome: 'part', completed_at: Date.parse('3/1/2021'))
    }
    let(:decision_override) { create(:decision_override, application: application) }
    let(:benefit_override) { create(:benefit_override, application: application, correct: true) }

    let(:row) do
      [application, evidence_check, hmrc_check, part_payment, decision_override, benefit_override].each(&:itself)
      CSV.parse(ocmc_export.to_csv, headers: true).first
    end

    it 'fills every column with the expected value' do
      aggregate_failures do
        expect(row['Office']).to eq('Cardiff')
        expect(row['Id']).to eq(application.id.to_s)
        expect(row['Status']).to eq('Completed')
        expect(row['HwF reference number']).to eq('GOLD0001')
        expect(row['Created at']).to eq('2021-01-02 00:00:00')
        expect(row['Fee']).to eq('410.0')
        expect(row['Jurisdiction']).to eq('County Court')
        expect(row['Application type']).to eq('income')
        expect(row['Form']).to eq('N1A')
        expect(row['Refund']).to eq('false')
        expect(row['Emergency']).to eq('true')
        expect(row['Applicant pays estimate']).to eq('50.0')
        expect(row['Pre evidence income']).to eq('89')
        expect(row['Post evidence income']).to eq('1500')
        expect(row['Low income declared']).to eq('true')
        expect(row['Decision date']).to eq('2021-01-02 00:00:00')
        expect(row['Income period']).to eq('last_month')
        expect(row['Children']).to eq('2')
        expect(row['Age band under 14']).to eq('1')
        expect(row['Age band 14+']).to eq('1')
        expect(row['Applicant pays']).to eq('0.0')
        expect(row['Departmental cost estimate']).to eq('360.0')
        expect(row['Departmental cost']).to eq('410.0')
        expect(row['Source']).to eq('paper')
        expect(row['Granted?']).to eq('yes')
        expect(row['Benefits granted?']).to eq('Yes')
        expect(row['Evidence checked?']).to eq('yes')
        expect(row['Capital band']).to eq('0 - 2,999')
        expect(row['Saving and Investments']).to eq('1500.0')
        expect(row['Case number']).to eq('GOLD0001')
        expect(row['Date received']).to eq('2021-01-01')
        expect(row['Date submitted online']).to eq('2020-11-01 00:00:00')
        expect(row['Married']).to eq('yes')
        expect(row['Pension age']).to eq('No')
        expect(row['Decision']).to eq('full')
        expect(row['Failed on savings']).to eq('No')
        expect(row['Application processed date']).to eq('2021-01-03 00:00:00')
        expect(row['Manual evidence processed date']).to eq('N/A')
        expect(row['Processed date']).to eq('2021-01-03 00:00:00')
        expect(row['EV check outcome']).to eq('full')
        expect(row['PP outcome']).to eq('part')
        expect(row['Declared income sources']).to eq('Wages before tax and National Insurance are taken off')
        expect(row['DB evidence check type']).to eq('random')
        expect(row['DB income check type']).to eq('hmrc')
        expect(row['HMRC total income']).to eq('1500.0')
        expect(row['Evidence check type']).to eq('HMRC NumberRule')
        expect(row['HMRC response?']).to eq('Yes')
        expect(row['HMRC errors']).to eq('N/A')
        expect(row['Complete processing?']).to eq('Yes')
        expect(row['Additional income']).to eq('50')
        expect(row['Income processed']).to eq('1500')
        expect(row['HMRC request date range']).to eq('1/1/2021 - 31/1/2021')
        expect(row['Statement signed by']).to eq('legal_representative')
        expect(row['Partner NI entered']).to eq('true')
        expect(row['Partner name entered']).to eq('true')
        expect(row['HwF Scheme']).to eq('post_ucd')
        expect(row['Deletion Reason']).to eq('N/A')
        expect(row['Reason Description']).to eq('N/A')
      end
    end
  end

  describe 'Source column' do
    before do
      travel_to(date_from + 1.day) do
        create(:application, :processed_state, office: office, reference: 'HWF-A79-JMN')
        create(:application, :processed_state, office: office, reference: 'PA21-0123456')
      end
    end

    it 'flags HWF-prefixed references as digital and others as paper' do
      csv = CSV.parse(ocmc_export.to_csv, headers: true)
      digital_row = csv.find { |row| row['HwF reference number'] == 'HWF-A79-JMN' }
      paper_row = csv.find { |row| row['HwF reference number'] == 'PA21-0123456' }

      aggregate_failures do
        expect(digital_row['Source']).to eq('digital')
        expect(paper_row['Source']).to eq('paper')
      end
    end
  end

  describe 'online applications without a linked paper Application' do
    let(:receiving_user) { create(:user, office: office) }

    context 'when date_received is filled in' do
      before do
        travel_to(date_from + 1.day) do
          create(:online_application,
                 reference: 'HWF-B82-KPQ',
                 date_received: Date.parse('2021-01-02'),
                 user_id: receiving_user.id)
        end
      end

      let(:row) { CSV.parse(ocmc_export.to_csv, headers: true).find { |r| r['HwF reference number'] == 'HWF-B82-KPQ' } }

      it 'appears in the report' do
        expect(row).not_to be_nil
      end

      it "shows the receiving user's office name in the Office column" do
        expect(row['Office']).to eq(office.name)
      end

      it 'sets Source to digital' do
        expect(row['Source']).to eq('digital')
      end

      it "fills paper-only columns with 'N/A'" do
        aggregate_failures do
          expect(row['Application processed date']).to eq('N/A')
          expect(row['EV check outcome']).to eq('N/A')
          expect(row['HMRC total income']).to eq('N/A')
          expect(row['Evidence check type']).to eq('N/A')
        end
      end
    end

    context 'when date_received is nil' do
      before do
        travel_to(date_from + 1.day) do
          create(:online_application,
                 reference: 'HWF-C13-LRS',
                 date_received: nil,
                 user_id: receiving_user.id)
        end
      end

      it 'does not appear in the report' do
        references = CSV.parse(ocmc_export.to_csv, headers: true)['HwF reference number']
        expect(references).not_to include('HWF-C13-LRS')
      end
    end

    context "when receiving user belongs to a different office (single-office mode)" do
      let(:other_office) { create(:office, name: 'Manchester') }
      let(:other_user) { create(:user, office: other_office) }

      before do
        travel_to(date_from + 1.day) do
          create(:online_application,
                 reference: 'HWF-OTH-001',
                 date_received: Date.parse('2021-01-02'),
                 user_id: other_user.id)
        end
      end

      it 'is excluded from the report' do
        references = CSV.parse(ocmc_export.to_csv, headers: true)['HwF reference number']
        expect(references).not_to include('HWF-OTH-001')
      end
    end

    context 'when receiving user belongs to Digital or HMCTS HQ Team' do
      let(:digital_user) { create(:user, office: digital_office) }
      let(:hq_user) { create(:user, office: hmcts_hq_office) }

      before do
        travel_to(date_from + 1.day) do
          create(:online_application,
                 reference: 'HWF-DIG-001',
                 date_received: Date.parse('2021-01-02'),
                 user_id: digital_user.id)
          create(:online_application,
                 reference: 'HWF-HQ-001',
                 date_received: Date.parse('2021-01-02'),
                 user_id: hq_user.id)
        end
      end

      it 'excludes both rows' do
        references = CSV.parse(ocmc_export.to_csv, headers: true)['HwF reference number']
        aggregate_failures do
          expect(references).not_to include('HWF-DIG-001')
          expect(references).not_to include('HWF-HQ-001')
        end
      end
    end

    context 'when user_id is nil (defensive)' do
      before do
        travel_to(date_from + 1.day) do
          create(:online_application,
                 reference: 'HWF-NIL-001',
                 date_received: Date.parse('2021-01-02'),
                 user_id: nil)
        end
      end

      it 'is excluded from the report (cannot determine office)' do
        references = CSV.parse(ocmc_export.to_csv, headers: true)['HwF reference number']
        expect(references).not_to include('HWF-NIL-001')
      end
    end
  end

  describe 'all_offices: true with online applications' do
    subject(:ocmc_export) { described_class.new(from_date, to_date, office_id, all_offices: true) }

    let(:bristol_user) { create(:user, office: bristol_office) }
    let(:cardiff_user) { create(:user, office: cardiff_office) }
    let(:digital_user) { create(:user, office: digital_office) }
    let(:hq_user)      { create(:user, office: hmcts_hq_office) }

    before do
      travel_to(date_from + 1.day) do
        create(:online_application, reference: 'HWF-AO-BR1', date_received: Date.parse('2021-01-02'), user_id: bristol_user.id)
        create(:online_application, reference: 'HWF-AO-CD1', date_received: Date.parse('2021-01-02'), user_id: cardiff_user.id)
        create(:online_application, reference: 'HWF-AO-DG1', date_received: Date.parse('2021-01-02'), user_id: digital_user.id)
        create(:online_application, reference: 'HWF-AO-HQ1', date_received: Date.parse('2021-01-02'), user_id: hq_user.id)
      end
    end

    context 'with a specific office_id present' do
      let(:office_id) { bristol_office.id }

      it 'includes online apps from non-excluded offices and excludes Digital / HMCTS HQ Team' do
        csv = CSV.parse(ocmc_export.to_csv, headers: true)
        rows = csv.map { |r| [r['HwF reference number'], r['Office']] }

        aggregate_failures do
          expect(rows).to include(['HWF-AO-BR1', 'Bristol'])
          expect(rows).to include(['HWF-AO-CD1', 'Cardiff'])
          expect(rows.map(&:first)).not_to include('HWF-AO-DG1')
          expect(rows.map(&:first)).not_to include('HWF-AO-HQ1')
        end
      end
    end

    context 'with nil office_id (regression: must not raise)' do
      let(:office_id) { nil }

      it 'does not raise and still produces the all-offices report' do
        expect { ocmc_export.to_csv }.not_to raise_error
        csv = CSV.parse(ocmc_export.to_csv, headers: true)
        rows = csv.map { |r| [r['HwF reference number'], r['Office']] }

        aggregate_failures do
          expect(rows).to include(['HWF-AO-BR1', 'Bristol'])
          expect(rows).to include(['HWF-AO-CD1', 'Cardiff'])
        end
      end
    end
  end

  describe 'online application that has been linked to a paper Application' do
    let(:linked_online) { create(:online_application, reference: 'HWF-D24-MTU', date_received: Date.parse('2021-01-02')) }

    before do
      travel_to(date_from + 1.day) do
        create(:application, :processed_state,
               office: office,
               online_application: linked_online,
               reference: 'HWF-D24-MTU')
      end
    end

    it 'appears exactly once (via the paper Application, not the online one)' do
      references = CSV.parse(ocmc_export.to_csv, headers: true)['HwF reference number']
      expect(references.count('HWF-D24-MTU')).to eq(1)
    end
  end
end
