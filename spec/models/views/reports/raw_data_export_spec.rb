# coding: utf-8

require 'rails_helper'

RSpec.describe Views::Reports::RawDataExport do
  subject(:data) { described_class.new(start_date_params, end_date_params) }

  let(:office) { create(:office) }
  let(:decision_date) { Time.zone.now.freeze }
  let(:shared_parameters) { { office: office, business_entity: business_entity, decision_date: } }
  let(:business_entity) { create(:business_entity, sop_code: 135864) }
  let(:start_date) { Time.zone.today - 1.month }
  let(:start_date_params) {
    { day: start_date.day, month: start_date.month, year: start_date.year }
  }
  let(:end_date) { Time.zone.today + 1.month }
  let(:end_date_params) {
    { day: end_date.day, month: end_date.month, year: end_date.year }
  }
  let(:digital_office) { create(:office, name: 'Digital') }

  describe 'when initialised with valid data' do
    it { is_expected.to be_a described_class }
  end

  describe '#to_csv' do
    before { create_list(:application_full_remission, 7, :processed_state, shared_parameters) }

    subject { data.to_csv }

    it { is_expected.to be_a String }

  end

  describe 'data returned should only include processed applications' do
    subject { data.total_count }

    let(:alternative_parameters) { { office: create(:office), business_entity: create(:business_entity), decision_date: } }
    let(:ignore_these_parameters) { { office: digital_office, business_entity: business_entity, decision_date: } }
    before do
      # include these
      create_list(:application_full_remission, 1, :processed_state, shared_parameters)
      create(:application_full_remission, :processed_state, alternative_parameters)
      create(:application_part_remission, :processed_state, shared_parameters)
      create(:application_no_remission, :processed_state, shared_parameters)
      # and exclude the following
      create(:application_full_remission, :processed_state, business_entity: business_entity, decision_date: 2.months.ago.freeze)
      create(:application_full_remission, :processed_state, ignore_these_parameters)
      create(:application_full_remission, :waiting_for_evidence_state, shared_parameters)
      create(:application_full_remission, :waiting_for_part_payment_state, shared_parameters)
      create(:application_full_remission, :deleted_state, shared_parameters)
    end

    it {
      expected_records_in_db = Application.where(state: 3, decision_date: start_date..end_date).where.not(office_id: digital_office.id)
      # testing duplications cause by sql
      expect(expected_records_in_db.count).to eq 4
      is_expected.to eq 4
    }
  end

  describe 'cost estimations' do
    let(:evidence_check_part) { create(:evidence_check_part_outcome, amount_to_pay: 100, application: part_ec, income: 1005) }
    let(:evidence_check_full) { create(:evidence_check_full_outcome, amount_to_pay: 0, application: full_ec, income: 222) }
    let(:evidence_check_none) { create(:evidence_check_incorrect, amount_to_pay: 300.34, application: none_ec, income: 5555, income_check_type: 'paper', completed_at: Date.parse('2025/1/1')) }
    let(:part_payment_none) { create(:part_payment_none_outcome) }
    let(:part_payment_return) { create(:part_payment_return_outcome) }
    let(:part_payment_part) { create(:part_payment_part_outcome, completed_at: Date.parse('1/3/2025')) }

    let(:applicant1) { none_no_ec.applicant }
    let(:applicant2) { none_ec.applicant }
    let(:applicant3) { full_no_ec.applicant }
    let(:dob) { 30.years.ago }
    let(:over_66) { false }
    let(:date_received) { Time.zone.today }
    let(:date_online_received) { Time.zone.today }
    let(:partner_over_66) { nil }
    let(:online_application) { create(:online_application, created_at: date_online_received) }

    before {
      evidence_check_part
      evidence_check_full
      evidence_check_none
      applicant1.update(married: true, ho_number: 'L123456', ni_number: nil)
      applicant2.update(married: true, ni_number: 'SN123456C', ho_number: nil, date_of_birth: dob, partner_ni_number: '')
      applicant3.update(married: true, ni_number: nil, ho_number: nil, partner_ni_number: 'SN896325A')
    }
    let(:full_no_ec) {
      create(:application_full_remission, :processed_state, :applicant_full,
             decision_date:, office: office, business_entity: business_entity,
             amount_to_pay: 0, decision_cost: 300.24, income_min_threshold_exceeded: true,
             detail: full_no_ec_detail, children_age_band: { one: 1, two: 0 }, income_period: 'last_month')
    }
    let(:full_no_ec_detail) { create(:complete_detail, :litigation_friend, case_number: 'JK123455B', fee: 300.24, jurisdiction: business_entity.jurisdiction, calculation_scheme: 'post_ucd') }

    let(:part_no_ec) {
      create(:application_part_remission, :processed_state,
             decision_date:, office: office, business_entity: business_entity,
             amount_to_pay: 50, decision_cost: 250, part_payment: part_payment_part, detail: part_no_ec_detail, income_period: 'average')
    }
    let(:part_no_ec_detail) { create(:complete_detail, :legal_representative, case_number: 'JK123456C', fee: 300, jurisdiction: business_entity.jurisdiction, calculation_scheme: 'pre_ucd') }

    let(:part_no_ec_return_pp) {
      create(:application_part_remission, :processed_state,
             decision_date:, office: office, business_entity: business_entity,
             amount_to_pay: 50.6, decision_cost: 0, part_payment: part_payment_return, detail: part_no_ec_return_pp_detail)
    }

    let(:part_no_ec_return_pp_detail) { create(:complete_detail, :applicant, case_number: 'JK123456F', fee: 300.45, jurisdiction: business_entity.jurisdiction) }

    let(:part_no_ec_none_pp) {
      create(:application_part_remission, :processed_state, decision_date:, office: office, business_entity: business_entity,
                                                            amount_to_pay: 50.6, decision_cost: 0, fee: 300.45, part_payment: part_payment_none)
    }

    let(:full_ec) {
      create(:application_full_remission, :processed_state, decision_date:, office: office, business_entity: business_entity,
                                                            amount_to_pay: 0, decision_cost: 300, fee: 300)
    }

    let(:part_ec) {
      create(:application_part_remission, :processed_state, decision_date:, office: office, business_entity: business_entity,
                                                            amount_to_pay: 50, decision_cost: 200, fee: 300, children_age_band: { one: 1, two: 2 })
    }

    let(:none_no_ec) {
      create(:application_no_remission, :processed_state, :applicant_full,
             decision_date:, office: office, business_entity: business_entity,
             amount_to_pay: 300.34, decision_cost: 0, fee: 300.34, children: 3, income: 2000, children_age_band: { one: 1, two: 2 })
    }

    let(:none_ec) {
      create(:application_no_remission, :processed_state, :applicant_full,
             decision_date:, office: office, business_entity: business_entity,
             amount_to_pay: 0, decision_cost: 0, children: 3, decision_type: none_decision_type,
             income: 2000, income_max_threshold_exceeded: true, detail: none_ec_detail,
             online_application: online_application, children_age_band: { one: 1, two: 2 }, saving: none_ec_saving)
    }
    let(:none_ec_detail) { create(:complete_detail, :applicant, case_number: 'JK123555F', fee: 300.34, date_received: date_received, jurisdiction: business_entity.jurisdiction) }
    let(:none_ec_saving) { create(:saving, over_66: over_66) }

    let(:none_under_100) { create(:application_no_remission, :processed_state, :applicant_full, decision_date:, office:, income: 100, business_entity: business_entity) }
    let(:none_benefits) { create(:application_no_remission, :processed_state, :applicant_full, decision_date:, office:, income: nil, business_entity: business_entity) }
    let(:none_decision_type) { 'application' }

    context 'no_remission under 100' do
      it do
        id = none_under_100.id
        reference = none_under_100.reference
        export = data.to_csv.split("\n")
        row = "#{id},#{office.name},#{reference}"
        matching_row = export.find { |line| line.include?(row) }
        expect(matching_row).to include('NI number,1,N/A,N/A,false,No,none,No,0.0,N/A,paper,false,N/A,false,Medium,3500.0,N/A,N/A,true,JK123456A')
      end
    end

    context 'no_remission benefits no income' do
      it do
        id = none_benefits.id
        reference = none_benefits.reference
        export = data.to_csv.split("\n")
        row = "#{id},#{office.name},#{reference}"
        matching_row = export.find { |line| line.include?(row) }
        expect(matching_row).to include('NI number,1,N/A,N/A,false,No,none,No,0.0,N/A,paper,false,N/A,false,Medium,3500.0,N/A,N/A,N/A,JK123456A')
      end
    end

    context 'full_remission' do
      it 'fills in estimated_cost based on fee and amount_to_pay' do
        full_no_ec
        export = data.to_csv
        jurisdiction = full_no_ec.detail.jurisdiction.name
        office = full_no_ec.office.name
        dob = full_no_ec.applicant.date_of_birth.to_fs
        date_received = full_no_ec.detail.date_received.to_fs
        row = "#{jurisdiction},135864,300.24,0.0,300.24,income,ABC123,false,false,10,N/A,last_month,None,1,1,0,true,No,full,No,0.0,300.24,paper,false"

        expect(export).to include(row)
        expect(export).to include("#{office},#{full_no_ec.reference}")
        completed_at = full_no_ec.completed_at.to_fs
        expect(export).to include("JK123455B,N/A,#{dob},#{date_received},#{decision_date.to_fs},N/A,#{completed_at},N/A,N/A,litigation_friend,false,false,post_ucd,N/A,N/A,N/A,N/A")
      end
    end

    context 'part_remission' do
      it 'fills in estimated_cost based on fee and amount_to_pay' do
        part_no_ec
        export = data.to_csv
        jurisdiction = part_no_ec.detail.jurisdiction.name
        row = "#{jurisdiction},135864,300.0,50.0,250.0,income,ABC123,false,false,2000,N/A,average,NI number,3,1,2,true,No,part,No,50.0,250.0,paper"
        dob = part_no_ec.applicant.date_of_birth.to_fs
        date_received = part_no_ec.detail.date_received.to_fs
        completed_at = part_no_ec.completed_at.to_fs

        expect(export).to include(row)
        expect(export).to include("true,part,false,JK123456C,N/A,#{dob},#{date_received},#{decision_date.to_fs},N/A,#{completed_at},N/A,N/A,legal_representative,true,true,pre_ucd,N/A,N/A,N/A,N/A")
      end

      it 'part payment outcome is "return"' do
        part_no_ec_return_pp
        export = data.to_csv
        jurisdiction = part_no_ec_return_pp.detail.jurisdiction.name
        date_received = part_no_ec_return_pp.detail.date_received.to_fs
        row = "#{jurisdiction},135864,300.45,50.6,249.85,income,ABC123,false,false,2000,N/A,last_month,NI number,3,1,2,true,No,part,No,300.45,0.0,paper"
        dob = part_no_ec_return_pp.applicant.date_of_birth.to_fs
        completed_at = part_no_ec_return_pp.completed_at.to_fs

        expect(export).to include(row)
        expect(export).to include("return,return,false,JK123456F,N/A,#{dob},#{date_received},#{decision_date.to_fs},N/A,#{completed_at},N/A,N/A,applicant,true,true,N/A,N/A,N/A,N/A,N/A")
      end

      it 'part payment outcome is "none"' do
        part_no_ec_none_pp
        export = data.to_csv
        jurisdiction = part_no_ec_none_pp.detail.jurisdiction.name
        row = "#{jurisdiction},135864,300.45,50.6,249.85,income,ABC123,false,false,2000,N/A,last_month,NI number,3,1,2,true,No,part,No,300.45,0.0,paper"
        part_no_ec_none_pp.applicant.date_of_birth.to_fs

        expect(export).to include(row)
        expect(export).to include("false,none,false,JK123456A")
      end
    end

    context 'no_remission' do
      it 'fills in estimated_cost based on fee and amount_to_pay' do
        none_no_ec
        export = data.to_csv
        jurisdiction = none_no_ec.detail.jurisdiction.name
        row = "#{jurisdiction},135864,300.34,300.34,0.0,income,ABC123,false,false,2000,N/A,N/A,Home Office number,3,1,2,true,No,none,No,300.34,0.0,paper,false,N/A,false,Medium,3500.0,N/A,N/A,false,JK123456A"
        expect(export).to include(row)
      end
    end

    context 'no_remission with evidence check' do
      let(:none_decision_type) { 'evidence_check' }

      it 'fills in estimated_cost based on fee and amount_to_pay' do
        none_ec
        export = data.to_csv
        jurisdiction = none_ec.detail.jurisdiction.name
        date_received = none_ec.detail.date_received.to_fs
        dob = none_ec.applicant.date_of_birth.to_fs
        postcode = none_ec.online_application.postcode
        online_date = none_ec.online_application.created_at.to_fs
        date_completed_ec = none_ec.evidence_check.completed_at.to_fs
        completed_at = none_ec.completed_at.to_fs
        row = "#{jurisdiction},135864,300.34,0.0,300.34,income,ABC123,false,false,2000,5555,N/A,NI number,3,1,2,true,No,none,No,300.34,0.0,paper"
        expect(export).to include(row)
        expect(export).to include("JK123555F,#{postcode},#{dob},#{date_received},#{decision_date.to_fs},N/A,#{completed_at},#{date_completed_ec},#{online_date},applicant,false,false,N/A,random,paper,0.0,none")
      end

      context 'over_66' do
        let(:over_66) { true }
        # it matters what they choose not dob filled
        let(:dob) { 60.years.ago }

        it 'fills in estimated_cost based on fee and amount_to_pay' do
          none_ec
          export = data.to_csv
          jurisdiction = none_ec.detail.jurisdiction.name
          row = "#{jurisdiction},135864,300.34,0.0,300.34,income,ABC123,false,false,2000,5555,N/A,NI number,3,1,2,true,Yes,none,No,300.34,0.0,paper"
          expect(export).to include(row)
          expect(export).to include("random,paper,0.0,none")
        end

        context 'date received' do
          let(:date_received) { 1.month.ago }
          let(:date_online_received) { 2.years.from_now }
          it 'fills in estimated_cost based on fee and amount_to_pay' do
            none_ec
            export = data.to_csv
            jurisdiction = none_ec.detail.jurisdiction.name
            row = "#{jurisdiction},135864,300.34,0.0,300.34,income,ABC123,false,false,2000,5555,N/A,NI number,3,1,2,true,Yes,none,No,300.34,0.0,paper"
            expect(export).to include(row)
            expect(export).to include("random,paper,0.0,none")
          end
        end
      end
    end

    context 'full_remission with evidence check' do
      it 'fills in estimated_cost based on fee and amount_to_pay' do
        full_ec
        export = data.to_csv
        jurisdiction = full_ec.detail.jurisdiction.name
        row = "#{jurisdiction},135864,300.0,0.0,300.0,income,ABC123,false,false,10,222,last_month,NI number,1,N/A,N/A,true,No,full,No,0.0,300.0,paper"
        expect(export).to include(row)
        expect(export).to include("random,N/A,0.0,full")
      end
    end

    context 'nil amount_to_pay defaults to zero' do
      let(:nil_amount_app) {
        create(:application_full_remission, :processed_state,
               decision_date:, office: office, business_entity: business_entity,
               amount_to_pay: nil, decision_cost: 300, fee: 300)
      }

      it 'exports zero for estimated and final amount to pay' do
        nil_amount_app
        export = data.to_csv
        jurisdiction = nil_amount_app.detail.jurisdiction.name
        row = "#{jurisdiction},135864,300.0,0.0,300.0"
        expect(export).to include(row)
      end
    end

    context 'part_remission with evidence check' do
      it 'fills in estimated_cost based on fee and amount_to_pay' do
        part_ec
        export = data.to_csv
        jurisdiction = part_ec.detail.jurisdiction.name
        row = "#{jurisdiction},135864,300.0,50.0,250.0,income,ABC123,false,false,2000,1005,last_month,NI number,3,1,2,true,No,part,No,100.0,200.0,paper"
        expect(export).to include(row)
        expect(export).to include("random,N/A,0.0,part")
      end
    end
  end

  describe 'savings values' do
    let(:date_fee_paid) { '' }
    subject { data.total_count }
    let(:application_no_remission) {
      create(:application_no_remission, :processed_state, :applicant_full, decision_date:, office: office, business_entity: business_entity,
                                                                           amount_to_pay: 300.34, decision_cost: 0, fee: 300.34, children: 3, income: 2000,
                                                                           date_received: date_received, date_fee_paid: date_fee_paid)
    }
    let(:applicant1) {
      application_no_remission.applicant
    }

    let(:savings_under_3_no_max) {
      application_no_remission.saving.update(min_threshold_exceeded: min_threshold, max_threshold_exceeded: max_threshold, amount: nil,
                                             passed: saving_passed, fee_threshold: nil, over_66: nil)
    }
    let(:saving_passed) { nil }

    before do
      savings_under_3_no_max
      applicant1.update(married: true, ho_number: 'L123456', ni_number: nil, date_of_birth: '25/11/2000')
    end

    context 'more then 16 - High (post-UCD)' do
      let(:date_received) { '10/11/2020' }
      let(:date_fee_paid) { '10/10/2020' }
      let(:min_threshold) { true }
      let(:max_threshold) { true }

      it {
        expect(Application.count).to eq 1
        is_expected.to eq 1
      }

      it 'true max true min threshold' do
        export = data.to_csv
        row = "paper,false,N/A,false,High,N/A,N/A,N/A,false,JK123456A,N/A,25/11/2000,10/11/2020,#{decision_date.to_fs}"

        expect(export).to include(row)
        expect(export).to include("Home Office number,3,N/A,N/A,true,No,none,N/A,300.34")
      end

      context 'saving passed' do
        let(:saving_passed) { true }

        it 'true max true min threshold' do
          export = data.to_csv
          row = "paper,false,N/A,false,High,N/A,N/A,N/A,false,JK123456A,N/A,25/11/2000,10/11/2020,#{decision_date.to_fs}"
          expect(export).to include(row)
          expect(export).to include("Home Office number,3,N/A,N/A,true,No,none,No,300.34")
        end
      end

      context 'saving failed' do
        let(:saving_passed) { false }

        it 'true max true min threshold' do
          export = data.to_csv
          row = "paper,false,N/A,false,High,N/A,N/A,N/A,false,JK123456A,N/A,25/11/2000,10/11/2020,#{decision_date.to_fs}"
          expect(export).to include(row)
          expect(export).to include("Home Office number,3,N/A,N/A,true,No,none,Yes,300.34")
        end
      end
    end

    context 'between 3 and 16 - Medium (post-UCD)' do
      let(:date_received) { '10/11/2020' }
      let(:min_threshold) { true }
      let(:max_threshold) { false }

      it 'false max true min threshold' do
        export = data.to_csv
        row = "paper,false,N/A,false,Medium,N/A,N/A,N/A,false,JK123456A,N/A,25/11/2000,10/11/2020,#{decision_date.to_fs}"
        expect(export).to include(row)
      end
    end

    context '3000 or more - High (pre-UCD)' do
      let(:date_received) { '12/11/2020' }
      let(:min_threshold) { true }
      let(:max_threshold) { nil }

      it 'nil max true min threshold' do
        export = data.to_csv
        row = "paper,false,N/A,false,High,N/A,N/A,N/A,false,JK123456A,N/A,25/11/2000,12/11/2020"
        expect(export).to include(row)
      end
    end

    context 'under 3000 - Low (pre-UCD)' do
      let(:date_received) { '10/11/2020' }
      let(:min_threshold) { false }
      let(:max_threshold) { nil }

      it 'false min and nil max threshold' do
        export = data.to_csv
        row = "paper,false,N/A,false,Low,N/A,N/A,N/A,false,JK123456A,N/A,25/11/2000,10/11/2020"
        expect(export).to include(row)
      end
    end

    context 'under 3000 max_threshold false - Low (post-UCD)' do
      let(:date_received) { '10/11/2020' }
      let(:min_threshold) { false }
      let(:max_threshold) { false }
      let(:benefit_overrides) { create(:benefit_override, application: application_no_remission, correct: correct_override) }
      let(:decision_overrides) { create(:decision_override, application: application_no_remission) }
      let(:correct_override) { true }

      it 'false min and false max threshold' do
        export = data.to_csv
        row = "paper,false,N/A,false,Low,N/A,N/A,N/A,false,JK123456A,N/A,25/11/2000,10/11/2020"
        expect(export).to include(row)
      end

      it 'with override details' do
        benefit_overrides
        decision_overrides

        export = data.to_csv
        row = "paper,true,Yes,false,Low,N/A,N/A,N/A,false,JK123456A,N/A,25/11/2000,10/11/2020"
        expect(export).to include(row)
      end

      context 'benefit override is false' do
        let(:correct_override) { false }

        it 'with override details' do
          benefit_overrides
          decision_overrides

          export = data.to_csv
          row = "paper,true,No,false,Low,N/A,N/A,N/A,false,JK123456A,N/A,25/11/2000,10/11/2020"
          expect(export).to include(row)
        end
      end

      it 'benefit override is correct - paper evidence provided' do
        benefit_overrides
        decision_overrides

        export = data.to_csv
        row = "paper,true,Yes,false,Low,N/A,N/A,N/A,false,JK123456A,N/A,25/11/2000,10/11/2020"
        expect(export).to include(row)
      end
    end

  end

  describe 'HMRC check data' do
    let(:date_fee_paid) { '' }
    let(:application2) { create(:application, :processed_state, office: office, decision_date: decision_date, business_entity: business_entity) }
    let(:date_range) { { date_range: { from: "1/7/2022", to: "31/7/2022" } } }
    let(:evidence_check) {
      create(:evidence_check_incorrect, amount_to_pay: 300.34, application: application2, income: 5555, hmrc_income_used: 512.10,
                                        check_type: 'flag', income_check_type: 'hmrc', completed_at: Date.parse('2025/1/1'))
    }
    let(:hmrc_check) {
      create(:hmrc_check, evidence_check: evidence_check,
                          created_at: 2.days.ago, income: nil, tax_credit: nil, request_params: date_range, additional_income: 100)
    }

    context 'part_remission with evidence check' do
      it 'fills in estimated_cost based on fee and amount_to_pay' do
        hmrc_check
        export = data.to_csv
        application2.detail.jurisdiction.name
        row = "flag,hmrc,512.1,none,HMRC NIFlag,Yes,N/A,Yes,100,5555,1/7/2022 - 31/7/2022"
        expect(export).to include(row)
      end
    end

    context 'avoid multiple checks for the same application' do
      before {
        create(:hmrc_check, evidence_check: evidence_check, created_at: 1.day.ago, income: { "taxablePay" => 1536 }, tax_credit: nil, request_params: date_range)
        create(:hmrc_check, evidence_check: evidence_check, created_at: 1.day.ago, income: { "taxablePay" => 1534 }, tax_credit: nil, request_params: date_range)
        create(:hmrc_check, evidence_check: evidence_check, created_at: 1.day.ago, income: { "taxablePay" => 1533 }, tax_credit: nil, request_params: date_range)
      }
      it { expect(data.total_count).to eq 1 }
    end
  end

  describe 'Income' do
    let(:date_fee_paid) { '' }
    let(:application2) { create(:application, :processed_state, office: office, decision_date: decision_date, business_entity: business_entity, income: income) }
    let(:date_range) { { date_range: { from: "1/7/2022", to: "31/7/2022" } } }

    context 'low income' do
      let(:income) { 101 }
      it do
        application2
        export = data.to_csv
        row = "false,N/A,false,Medium,3500.0,N/A,N/A,true,JK123456A"
        expect(export).to include(row)
      end
    end

    context 'not low income' do
      let(:income) { 102 }
      it do
        application2
        export = data.to_csv
        row = "false,N/A,false,Medium,3500.0,N/A,N/A,false,JK123456A"
        expect(export).to include(row)
      end
    end

    context 'blank income is N/A value' do
      let(:income) { nil }
      it do
        application2
        export = data.to_csv
        row = "false,N/A,false,Medium,3500.0,N/A,N/A,N/A,JK123456A"
        expect(export).to include(row)
      end
    end
  end
end
