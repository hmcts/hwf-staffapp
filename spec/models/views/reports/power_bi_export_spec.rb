# coding: utf-8

require 'rails_helper'

RSpec.describe Views::Reports::PowerBiExport do
  subject(:power_bi_export) { described_class.new }

  describe 'init' do

    it 'generates csv data' do
      allow(CSV).to receive(:generate).and_return 'test'
      power_bi_export
      expect(CSV).to have_received(:generate)
    end

    it 'zips csv data' do
      allow(CSV).to receive(:generate).and_return "test"
      allow(Zip::File).to receive(:open)
      power_bi_export
      expect(Zip::File).to have_received(:open)
    end

    it 'zipe file exist in the path' do
      allow(CSV).to receive(:generate).and_return "test"
      pn = Pathname.new(power_bi_export.zipfile_path)
      expect(pn.file?).to be true
    end

    it 'remove the file' do
      allow(CSV).to receive(:generate).and_return "test"
      pn = Pathname.new(power_bi_export.zipfile_path)
      power_bi_export.tidy_up
      expect(pn.file?).not_to be true
    end
  end

end
