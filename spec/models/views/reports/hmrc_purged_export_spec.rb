# coding: utf-8

require 'rails_helper'

RSpec.describe Views::Reports::HmrcPurgedExport do
  subject(:hmrc_export) { described_class.new(date_from, date_to) }
  let(:from_date) { { day: date_from.day, month: date_from.month, year: date_from.year } }
  let(:to_date) { { day: date_to.day, month: date_to.month, year: date_to.year } }

  let(:date_from) { Date.parse('1/1/2021') }
  let(:date_to) { Date.parse('1/2/2021') }
  let(:application1) { create(:application, :with_office, :with_reference) }
  let(:application2) { create(:application, :with_office, :with_reference) }
  describe 'to_csv' do
    let(:evidence_check1) { create(:evidence_check, application: application1) }
    let(:evidence_check2) { create(:evidence_check, application: application2) }
    let(:hmrc_check1) { create(:hmrc_check, evidence_check: evidence_check1, ni_number: 'SN123451', date_of_birth: '01/01/1980', request_params: { date_range: { from: "1/2/2018", to: "1/3/2018" } }) }
    let(:hmrc_check2) { create(:hmrc_check, evidence_check: evidence_check1, ni_number: 'SN123452', date_of_birth: '01/02/1981', request_params: { date_range: { from: "1/2/2019", to: "1/3/2019" } }) }
    let(:hmrc_check3) { create(:hmrc_check, evidence_check: evidence_check1, ni_number: 'SN123453', date_of_birth: '01/03/1982', request_params: { date_range: { from: "1/2/2020", to: "1/3/2020" } }) }
    let(:hmrc_check4) { create(:hmrc_check, evidence_check: evidence_check2, ni_number: 'SN123454', date_of_birth: '01/04/1983', request_params: { date_range: { from: "1/2/2021", to: "1/3/2021" } }) }
    let(:hmrc_check5) { create(:hmrc_check, evidence_check: evidence_check2, ni_number: 'SN123455', date_of_birth: '01/05/1984', request_params: { date_range: { from: "1/2/2022", to: "1/3/2022" } }) }

    subject(:data) { hmrc_export.to_csv.split("\n") }

    before do
      travel_to(date_from + 1.day) { hmrc_check1 }
      travel_to(date_from + 5.days) { hmrc_check2 }
      travel_to(date_from + 3.days) { hmrc_check3 }
      travel_to(date_to + 1.day) { hmrc_check4 }
      travel_to(date_from - 1.day) { hmrc_check5 }
    end

    it 'return 4 rows csv data' do
      expect(data.count).to be(4)
    end

    it 'first row are keys' do
      keys = "Date created,Office,BE code,Staff member,Date purged,HWF reference,Applicant DOB,Date range HMRC data requested for,PAYE data,Child Tax Credit,Work Tax Credit"
      expect(data[0]).to eq(keys)
    end

    context 'order by created at' do
      it { expect(data[1]).to include(hmrc_check1.evidence_check.application.reference) }
      it { expect(data[2]).to include(hmrc_check3.evidence_check.application.reference) }
      it { expect(data[3]).to include(hmrc_check2.evidence_check.application.reference) }
    end

    context 'in given timeframe' do
      it { expect(data.join).not_to include(hmrc_check4.evidence_check.application.reference) }
      it { expect(data.join).not_to include(hmrc_check5.evidence_check.application.reference) }
    end

    context 'hmrc data' do
      let(:user) { hmrc_check1.evidence_check.application.user }
      let(:office) { hmrc_check1.evidence_check.application.office }
      let(:expected_line) { "2021-01-02 00:00:00,#{office.name},N/A,#{user.name},N/A,AB001-21-1,01/01/1980,1/2/2018 to 1/3/2018,present,empty,present" }
      it { expect(data[1]).to eq expected_line }
    end

    context 'hmrc data empty' do
      before {
        hmrc_check3.evidence_check.application.update(business_entity: business_entity)
      }
      let(:evidence_check3) { create(:evidence_check, application: application3) }
      let(:business_entity) { create(:business_entity, sop_code: 'SOP123') }
      let(:hmrc_check3) { create(:hmrc_check, evidence_check: evidence_check3, ni_number: 'SN123453', date_of_birth: '01/03/1982', request_params: nil, tax_credit: nil, income: nil) }
      let(:application3) { create(:application, :with_office, :with_reference) }
      let(:user) { application3.user }
      let(:office) { application3.office }
      let(:expected_line) { "2021-01-04 00:00:00,#{office.name},SOP123,#{user.name},N/A,#{application3.reference},01/03/1982,N/A,empty,empty,empty" }
      it { expect(data[2]).to eq expected_line }
    end
  end
end
