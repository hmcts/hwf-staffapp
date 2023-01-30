require 'rails_helper'

RSpec.describe Views::Reports::ApplicantsPerFyExport do
  describe '#initialize' do
    it 'creates a hash with counts' do
      date_from = DateTime.new(2018, 4, 1)
      date_to = DateTime.new(2021, 3, 31)
      instance = described_class.new(date_from, date_to)
      expect(instance).to have_attributes(result: be_a(Hash))
    end
  end

  describe '#to_csv' do
    it 'generates csv' do
      date_from = DateTime.new(2018, 4, 1)
      date_to = DateTime.new(2021, 3, 31)
      instance = described_class.new(date_from, date_to)
      expect(CSV).to receive(:generate)
      instance.to_csv
    end
  end

  describe '#hash_with_counts' do
    before {
      Timecop.freeze(Time.local(2020, 1, 1, 12, 0, 0)) {
        create(:application, :applicant_full, :processed_state)
      }

    }
    it 'correctly counts applicants' do
      date_from = DateTime.new(2018, 4, 1)
      date_to = DateTime.new(2021, 3, 31)
      instance = described_class.new(date_from, date_to)
      expect(instance.result.first.last['count']).to eq(1)
    end
  end
end
