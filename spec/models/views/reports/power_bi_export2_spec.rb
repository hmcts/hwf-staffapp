# coding: utf-8

require 'rails_helper'

RSpec.describe Views::Reports::PowerBiExport2 do
  subject(:power_bi_export) { described_class.new }

  describe 'the exported time frame' do
    context 'when run in May' do
      before { travel_to(Date.new(2026, 5, 15)) }

      it 'builds the previous calendar month (April) pulled on created_at' do
        new_export = instance_double(Views::Reports::PowerBiNewExport, export2_by_created_at: 'tmp/export2.zip')
        allow(Views::Reports::PowerBiNewExport).to receive(:new).
          with(Date.new(2026, 4, 1), Date.new(2026, 4, 30)).and_return(new_export)

        power_bi_export.to_zip

        expect(new_export).to have_received(:export2_by_created_at)
        expect(power_bi_export.zipfile_path).to eq 'tmp/export2.zip'
      end
    end

    context 'when run in January' do
      before { travel_to(Date.new(2026, 1, 5)) }

      it 'rolls back to December of the previous year' do
        new_export = instance_double(Views::Reports::PowerBiNewExport, export2_by_created_at: 'tmp/export2.zip')
        allow(Views::Reports::PowerBiNewExport).to receive(:new).
          with(Date.new(2025, 12, 1), Date.new(2025, 12, 31)).and_return(new_export)

        power_bi_export.to_zip

        expect(new_export).to have_received(:export2_by_created_at)
      end
    end

    context 'when given a specific month' do
      subject(:power_bi_export) { described_class.new(Date.new(2025, 11, 9)) }

      it 'builds that whole month pulled on created_at' do
        new_export = instance_double(Views::Reports::PowerBiNewExport, export2_by_created_at: 'tmp/export2.zip')
        allow(Views::Reports::PowerBiNewExport).to receive(:new).
          with(Date.new(2025, 11, 1), Date.new(2025, 11, 30)).and_return(new_export)

        power_bi_export.to_zip

        expect(new_export).to have_received(:export2_by_created_at)
      end
    end
  end

  describe 'output' do
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
