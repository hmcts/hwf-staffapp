require 'rails_helper'

RSpec.describe FileDownloadHelper do
  describe '#download_file_page_header' do
    it 'names the raw data extract' do
      storage = build(:export_file_storage, name: 'raw_data')
      expect(helper.download_file_page_header(storage)).to eq 'Raw Data'
    end

    it 'names a Power BI extract' do
      storage = build(:export_file_storage, name: 'power_bi_export_2')
      expect(helper.download_file_page_header(storage)).to eq 'PowerBI extract two'
    end
  end
end
