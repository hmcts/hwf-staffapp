require 'rails_helper'

# A date of death on the citizen record is flagged when it is on or before the
# application date. See CHANGELOG.md
RSpec.describe BenefitCheckers::DateOfDeath do
  subject(:flagged) { described_class.flagged(citizen_record, application_date) }

  let(:application_date) { Date.new(2026, 9, 30) }

  def record_with(date = nil)
    attributes = { 'guid' => 'guid' }
    attributes['dateOfDeath'] = { 'date' => date, 'metadata' => { 'verificationType' => 'authoritative' } } if date
    { 'data' => { 'id' => 'guid', 'type' => 'Citizen', 'attributes' => attributes } }
  end

  context 'when the citizen died before the application date' do
    let(:citizen_record) { record_with('2022-01-05') }

    it { is_expected.to eq Date.new(2022, 1, 5) }
  end

  context 'when the citizen died on the application date' do
    let(:citizen_record) { record_with('2026-09-30') }

    it { is_expected.to eq application_date }
  end

  context 'when the citizen died after the application date' do
    let(:citizen_record) { record_with('2026-10-01') }

    it { is_expected.to be_nil }
  end

  context 'when the citizen record has no date of death' do
    let(:citizen_record) { record_with }

    it { is_expected.to be_nil }
  end

  context 'when there is no citizen record' do
    let(:citizen_record) { nil }

    it { is_expected.to be_nil }
  end

  ['05/01/2022', '2022-1-5', '2022-13-40', 'unknown', ''].each do |value|
    context "when the date of death is #{value.inspect}" do
      let(:citizen_record) { record_with(value) }

      it { is_expected.to be_nil }
    end
  end

  context 'when the application has no date to compare with' do
    let(:application_date) { nil }
    let(:citizen_record) { record_with('2022-01-05') }

    it { is_expected.to be_nil }
  end
end
