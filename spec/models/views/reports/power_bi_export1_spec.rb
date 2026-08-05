# coding: utf-8

require 'rails_helper'

RSpec.describe Views::Reports::PowerBiExport1 do
  subject(:power_bi_export) { described_class.new }

  describe 'the exported time frame' do
    context 'when run in May' do
      before { travel_to(Date.new(2026, 5, 15)) }

      it 'exports the whole of the previous calendar month (April)' do
        expect(power_bi_export.zipfile_path).to eq 'tmp/power_bi_export_1-1-4-2026-30-4-2026.csv.zip'
      end
    end

    context 'when run in March' do
      before { travel_to(Date.new(2026, 3, 10)) }

      it 'exports the whole of the previous calendar month (February)' do
        expect(power_bi_export.zipfile_path).to eq 'tmp/power_bi_export_1-1-2-2026-28-2-2026.csv.zip'
      end
    end

    context 'when run in January' do
      before { travel_to(Date.new(2026, 1, 5)) }

      it 'rolls back to December of the previous year' do
        expect(power_bi_export.zipfile_path).to eq 'tmp/power_bi_export_1-1-12-2025-31-12-2025.csv.zip'
      end
    end

    context 'when given a specific month' do
      subject(:power_bi_export) { described_class.new(Date.new(2025, 11, 9)) }

      it 'exports the whole of that month' do
        expect(power_bi_export.zipfile_path).to eq 'tmp/power_bi_export_1-1-11-2025-30-11-2025.csv.zip'
      end
    end
  end

  describe 'output' do
    it 'reuses the raw data extract (same fields and logic)' do
      expect(described_class.ancestors).to include(Views::Reports::RawDataExport)
    end

    it 'generates a zip file at the given path' do
      power_bi_export.to_zip
      expect(Pathname.new(power_bi_export.zipfile_path).file?).to be true
    end

    it 'removes the file on tidy up' do
      power_bi_export.to_zip
      pn = Pathname.new(power_bi_export.zipfile_path)
      power_bi_export.tidy_up
      expect(pn.file?).not_to be true
    end
  end
end
