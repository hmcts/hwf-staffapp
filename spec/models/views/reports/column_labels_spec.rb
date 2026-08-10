# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Views::Reports::ColumnLabels do
  describe 'LABELS' do
    it 'is frozen and non-empty' do
      expect(described_class::LABELS).to be_frozen
      expect(described_class::LABELS).not_to be_empty
    end

    it 'has no duplicate labels (each concept is spelled one way, and no two collide)' do
      values = described_class::LABELS.values
      duplicates = values.select { |v| values.count(v) > 1 }.uniq

      expect(duplicates).to be_empty, "duplicate labels: #{duplicates.inspect}"
    end
  end

  describe '.fetch' do
    it 'returns the canonical label for a known key' do
      expect(described_class.fetch(:reference)).to eq('HwF reference number')
    end

    it 'raises for an unknown key so typos fail loudly' do
      expect { described_class.fetch(:nonsense) }.to raise_error(KeyError)
    end
  end

  describe '.for' do
    it 'maps an ordered list of keys to their labels' do
      expect(described_class.for([:id, :office])).to eq(['Id', 'Office'])
    end
  end

  # These bind each export's headers to the single source of truth: if anyone
  # hardcodes a stray or misspelled header, or a key drops out of ColumnLabels,
  # one of these fails instead of shipping an inconsistent export.
  describe 'exports use only canonical labels' do
    it 'RawDataExport headers are all canonical' do
      stray = Views::Reports::RawDataExport::HEADERS - described_class::LABELS.values
      expect(stray).to be_empty, "non-canonical raw headers: #{stray.inspect}"
    end

    it 'PowerBiNewExport headers are built from ColumnLabels in order' do
      expect(Views::Reports::PowerBiNewExport::HEADERS).
        to eq(described_class.for(Views::Reports::PowerBiNewExport::HEADER_KEYS))
    end
  end
end
