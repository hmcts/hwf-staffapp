# coding: utf-8

require 'rails_helper'

RSpec.describe Views::Reports::HmrcOcmcDataExport do
  subject(:ocmc_export) { described_class.new(from_date, to_date, 164, all_offices: false, all_datashare_offices: true) }
  let(:from_date) { { day: date_from.day, month: date_from.month, year: date_from.year } }
  let(:to_date) { { day: date_to.day, month: date_to.month, year: date_to.year } }

  let(:office) { create(:office, id: 164, name: 'test office') }
  let(:office2) { create(:office, id: 167, name: 'appearing office') }
  let(:office3) { create(:office, id: 165, name: 'another working office') }
  let(:date_from) { Date.parse('1/1/2021') }
  let(:date_to) { Date.parse('1/2/2021') }

  describe 'to_csv' do
    let(:application1) {
      create(:application, :processed_state, office: office, income_kind: {},
                                             detail: app1_detail, children_age_band: { one: 7, two: 8 }, income_period: 'last_month',
                                             created_at: date_from, reference: 'AB001-21-1', income: 500)
    }

    let(:app1_detail) { create(:complete_detail, :legal_representative, calculation_scheme: 'post_ucd') }

    let(:application2) {
      create(:application, :processed_state, office: office2, income_kind: {},
                                             children_age_band: { one: 7, two: 8 }, income_period: 'last_year',
                                             created_at: date_from, reference: 'AB001-21-2', income: 750)
    }

    let(:application3) {
      create(:application, :processed_state, office: office3, income_kind: {},
                                             created_at: date_from, reference: 'AB001-21-3', income: 805)
    }

    subject(:data) { ocmc_export.to_csv.split("\n") }

    before do
      Timecop.freeze(date_from + 1.day) { application1 }
      Timecop.freeze(date_from + 2.days) { application2 }
      Timecop.freeze(date_from + 3.days) { application3 }
      application1.applicant.update(partner_ni_number: 'SN789654C')
      ENV['HMRC_OFFICE_CODE'] = 'ABC123 ABC456'
      office.update!(entity_code: 'ABC123')
      office2.update!(entity_code: 'ABC123')
      office3.update!(entity_code: 'ABC456')
    end

    it 'return 4 rows csv data' do
      expect(data.count).to be(4)
    end

    context 'data fields' do

      it 'has headings' do
        data_row = data[0]
        expect(data_row).to include('Office,HwF reference number,Created at,Fee,Jurisdiction,Application type')
      end

      it 'uses the test offices' do
        data_row = data[1]
        expect(data_row).to include('another working office')
        data_row = data[2]
        expect(data_row).to include('appearing office')
        data_row = data[3]
        expect(data_row).to include('test office')
      end

      it 'displays formatted date' do
        data_row = data[1]
        expect(data_row).to include('2021-01-01 00:00:00')
      end

      it 'has correct reference numbers' do
        data_row = data[1]
        expect(data_row).to include('AB001-21-3')
        data_row = data[2]
        expect(data_row).to include('AB001-21-2')
        data_row = data[3]
        expect(data_row).to include('AB001-21-1')
      end

      it 'has correct incomes' do
        data_row = data[1]
        expect(data_row).to include('805')
        data_row = data[2]
        expect(data_row).to include('750')
        data_row = data[3]
        expect(data_row).to include('500')
      end

      it 'has correct income period' do
        data_row = data[2]
        expect(data_row).to include('last_year')
        data_row = data[3]
        expect(data_row).to include('last_month')
      end

    end

  end
end
