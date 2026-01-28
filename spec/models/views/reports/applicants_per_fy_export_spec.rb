require 'rails_helper'

RSpec.describe Views::Reports::ApplicantsPerFyExport do
  let(:fy_start) { 2018 }
  let(:fy_end) { 2019 }
  describe '#initialize' do
    it 'creates a hash with counts' do
      date_from = fy_start
      date_to = fy_end
      instance = described_class.new(date_from, date_to)
      expect(instance).to have_attributes(result: be_a(Hash))
    end
  end

  describe '#to_csv' do
    it 'generates csv' do
      allow(CSV).to receive(:generate)
      date_from = fy_start
      date_to = fy_end
      instance = described_class.new(date_from, date_to)
      instance.to_csv
      expect(CSV).to have_received(:generate)
    end
  end

  describe '#hash_with_counts' do
    let(:results) { instance_double(PG::Result) }
    let(:list) { [application1, application2, application3] }

    let(:application1) { create(:application, :applicant_full, :processed_state,  outcome: 'part', jurisdiction: jurisdiction1) }
    let(:application2) { create(:application, :applicant_full, :processed_state,  outcome: 'full', jurisdiction: jurisdiction1) }
    let(:application3) { create(:application, :applicant_full, :processed_state,  outcome: 'part', jurisdiction: jurisdiction1) }
    let(:application4) { create(:application, :applicant_full, :processed_state,  outcome: 'part', jurisdiction: jurisdiction2) }
    let(:jurisdiction1) { create(:jurisdiction, name: 'Jurisdiction 1') }
    let(:jurisdiction2) { create(:jurisdiction, name: 'Jurisdiction 2') }
    let(:fy_start) { 2019 }
    let(:fy_end) { 2020 }

    before {
      travel_to(Time.zone.local(2020, 1, 1, 12, 0, 0)) {
        application1.applicant.update(first_name: 'John', last_name: 'Doe', date_of_birth: '1980-01-01')
        application2.applicant.update(first_name: 'John', last_name: 'Mnemonic', date_of_birth: '1980-01-01')
        application3.applicant.update(first_name: 'John', last_name: 'Doe', date_of_birth: '1980-01-01')
        application4.applicant.update(first_name: 'John', last_name: 'Doe', date_of_birth: '1980-01-01')
      }

      allow(results).to receive(:each).and_return list
    }
    it 'correctly displays values' do
      instance = described_class.new(fy_start, fy_end)

      expect(instance.result['John-Doe-1980-01-01']['count']).to eq(3)
      expect(instance.result['John-Doe-1980-01-01']['jurisdiction']['Jurisdiction 1']).to eq(2)
      expect(instance.result['John-Doe-1980-01-01']['jurisdiction']['Jurisdiction 2']).to eq(1)
      expect(instance.result['John-Doe-1980-01-01']['decision']['part']).to eq(3)
      expect(instance.result['John-Mnemonic-1980-01-01']['decision']['full']).to eq(1)
      expect(instance.result['John-Mnemonic-1980-01-01']['jurisdiction']['Jurisdiction 1']).to eq(1)
      expect(instance.result['John-Mnemonic-1980-01-01']['jurisdiction']['Jurisdiction 2']).to eq(0)
      expect(instance.result.count).to eq(2)
    end

    it 'no results' do
      date_from = 2018
      date_to = 2019
      instance = described_class.new(date_from, date_to)

      expect(instance.result).to eq({})
    end
  end
end
