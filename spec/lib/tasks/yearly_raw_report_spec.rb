require 'rails_helper'

load Rails.root.join('lib/tasks/yearly_raw_report.rake')

RSpec.describe YearlyRawDataExporter do
  subject(:exporter) { described_class.new }

  let(:start_date) { Date.new(2025, 4, 1) }
  let(:end_date) { Date.new(2026, 3, 9) }

  let(:office) { create(:office) }
  let(:business_entity) { create(:business_entity, sop_code: 135_864) }
  let(:digital_office) { create(:office, name: 'Digital') }
  let(:hmcts_hq_office) { create(:office, name: 'HMCTS HQ Team') }
  let(:decision_date) { Date.new(2025, 6, 15) }
  let(:shared_parameters) { { office: office, business_entity: business_entity, decision_date: decision_date } }

  after do
    FileUtils.rm_rf(Rails.root.join("tmp/raw_data_exports"))
  end

  describe '#run' do
    it 'creates a CSV and ZIP file' do
      exporter.run

      output_dir = Rails.root.join("tmp/raw_data_exports")
      csv_files = Dir.glob(File.join(output_dir, '*.csv'))
      zip_files = Dir.glob(File.join(output_dir, '*.zip'))

      expect(csv_files.size).to eq(1)
      expect(zip_files.size).to eq(1)
    end
  end

  describe 'CSV output' do
    subject(:csv_content) do
      exporter.run
      output_dir = Rails.root.join("tmp/raw_data_exports")
      csv_file = Dir.glob(File.join(output_dir, '*.csv')).first
      File.read(csv_file)
    end

    it 'contains headers' do
      expect(csv_content).to include(
        'id,office,reference,jurisdiction,SOP code,fee,estimated applicant pay,estimated cost'
      )
    end

    it 'contains data for processed applications in the date range' do
      application = create(:application_full_remission, :processed_state, **shared_parameters, fee: 500)

      expect(csv_content).to include(application.reference)
      expect(csv_content).to include(office.name)
    end

    it 'excludes Digital office applications' do
      application = create(:application_full_remission, :processed_state,
                           office: digital_office, business_entity: business_entity,
                           decision_date: decision_date, fee: 500)

      expect(csv_content).not_to include(application.reference)
    end

    it 'excludes HMCTS HQ Team office applications' do
      application = create(:application_full_remission, :processed_state,
                           office: hmcts_hq_office, business_entity: business_entity,
                           decision_date: decision_date, fee: 500)

      expect(csv_content).not_to include(application.reference)
    end

    it 'excludes applications outside the date range' do
      application = create(:application_full_remission, :processed_state,
                           office: office, business_entity: business_entity,
                           decision_date: Date.new(2024, 1, 1), fee: 500)

      expect(csv_content).not_to include(application.reference)
    end

    it 'excludes non-processed applications' do
      application = create(:application_full_remission,
                           office: office, business_entity: business_entity,
                           decision_date: decision_date, fee: 500,
                           state: Application.states[:waiting_for_evidence])

      expect(csv_content).not_to include(application.reference)
    end
  end

  describe 'output matches RawDataExport' do
    before do
      create(:application_full_remission, :processed_state, **shared_parameters, fee: 500)
      create(:application_part_remission, :processed_state, **shared_parameters, fee: 300,
                                                                                 amount_to_pay: 50, decision_cost: 250)
    end

    it 'produces the same data rows as the original export' do
      exporter.run

      start_date_hash = { day: start_date.day, month: start_date.month, year: start_date.year }
      end_date_hash = { day: end_date.day, month: end_date.month, year: end_date.year }
      original_csv = Views::Reports::RawDataExport.new(start_date_hash, end_date_hash).to_csv

      output_dir = Rails.root.join("tmp/raw_data_exports")
      exporter_csv = File.read(Dir.glob(File.join(output_dir, '*.csv')).first)

      original_data_lines = original_csv.lines.drop(1).map(&:strip).reject(&:empty?).sort
      exporter_data_lines = exporter_csv.lines.drop(1).map(&:strip).reject(&:empty?).sort

      expect(exporter_data_lines).to eq(original_data_lines)
    end
  end
end
