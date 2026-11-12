require 'rails_helper'

RSpec.describe StatusNotification do
  describe '.for' do
    it 'creates the row for a service the first time' do
      expect { described_class.for('hmrc') }.to change(described_class, :count).by(1)
    end

    it 'starts with no outage open' do
      expect(described_class.for('hmrc')).to have_attributes(outage_open: false, sent_count: 0, last_sent_at: nil)
    end

    it 'returns the same row afterwards' do
      first = described_class.for('hmrc')
      expect(described_class.for('hmrc')).to eq(first)
    end
  end

  it 'allows one row per service' do
    described_class.create!(service: 'hmrc')
    expect { described_class.create!(service: 'hmrc') }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
