require 'rails_helper'

RSpec.describe ReportBase do
  # rubocop:disable Lint/ConstantDefinitionInBlock, RSpec/LeakyConstantDeclaration

  class TestReport < ReportBase
    def initialize
      @zipfile_path = 'tmp/test.zip'
      @csv_file_name = 'report_file.csv'
    end

    def to_csv
      ['134']
    end
  end
  # rubocop:enable Lint/ConstantDefinitionInBlock, RSpec/LeakyConstantDeclaration

  let(:report_class) { TestReport.new }

  describe '#to_zip' do
    it 'calls to csv' do
      zip_file = report_class.to_zip
      expect(zip_file).not_to be_nil
    end

    it 'calls generate file' do
      allow(report_class).to receive(:generate_file)

      report_class.to_zip
      expect(report_class).to have_received(:generate_file)
    end
  end

  describe '#format_dates' do
    it do
      dates = { day: '1', month: '12', year: '2024' }
      formatted = report_class.format_dates(dates)

      expect(formatted).to eq('1/12/2024')
    end
  end
end
