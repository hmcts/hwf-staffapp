# coding: utf-8

require 'rails_helper'

RSpec.describe Views::Reports::AuditPersonalDataReport do
  subject(:audit_export) { described_class.new(from_date, to_date) }
  let(:from_date) { { day: date_from.day, month: date_from.month, year: date_from.year } }
  let(:to_date) { { day: date_to.day, month: date_to.month, year: date_to.year } }

  let(:date_from) { Date.parse('1/1/2021') }
  let(:date_to) { Date.parse('1/2/2021') }

  let(:application1) { create(:application, :confirm) }
  let(:application2) { create(:application, :confirm) }
  let(:application3) { create(:application, :confirm, reference: '') }
  let(:application4) { create(:online_application, :with_reference, convert_to_application: true, purged: true) }

  describe 'to_csv' do
    subject(:data) { audit_export.to_csv.split("\n") }
    before {
      travel_to(Date.parse('1/1/2020')) {
        PersonalDataPurge.new([application1]).purge!
      }
      travel_to(Date.parse('1/11/2021')) {
        PersonalDataPurge.new([application2]).purge!
      }
      travel_to(Date.parse('10/1/2021')) {
        PersonalDataPurge.new([application3]).purge!
      }
      travel_to(Date.parse('12/1/2021')) {
        PersonalDataPurge.new([application4.linked_application]).purge!
      }
    }

    it 'return 4 rows csv data' do
      expect(data.count).to be(3)
    end

    it 'first row are keys' do
      keys = "Date data purged,HwF reference,deceased_name,case_number,ho_number,ni_number,title,first_name,last_name,address,email_address,phone"
      expect(data[0]).to eq(keys)
    end

    context 'purged data line 1' do
      let(:applicant) { application3.applicant }
      let(:detail) { application3.detail }

      let(:expected_line) {
        "#{application3.purged_at},N/A,purged,purged,purged,purged,purged,purged,purged,purged,purged,purged"
      }
      it { expect(data[1]).to eq expected_line }
    end

    context 'purged data line 2' do
      let(:applicant) { application4.applicant }
      let(:detail) { application4.detail }

      let(:expected_line) {
        application = application4.linked_application(:with_purged)
        [application.purged_at, application.reference, 'purged', 'purged', 'purged', 'purged', 'purged', 'purged', 'purged', 'purged', 'purged', 'purged']
      }
      it { expect(data[2]).to eq expected_line.join(',') }
    end

  end
end
