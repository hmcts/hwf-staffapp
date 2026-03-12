require 'rails_helper'

load Rails.root.join('lib/tasks/yearly_finance_transactional_report.rake')

RSpec.describe YearlyFinanceTransactionalExporter do
  subject(:exporter) { described_class.new }

  let(:current_time) { Time.zone.parse('2026-01-15 10:30:00') }
  let(:start_date) { Date.new(2025, 4, 1) }
  let(:end_date) { Date.new(2026, 3, 9) }

  let(:jurisdiction1) { create(:jurisdiction) }
  let(:jurisdiction2) { create(:jurisdiction) }
  let(:business_entity1) { create(:business_entity, sop_code: 'abc134', jurisdiction: jurisdiction1) }
  let(:business_entity2) { create(:business_entity, sop_code: 'efg142', jurisdiction: jurisdiction2) }
  let(:digital_office) { create(:office, name: 'Digital') }

  after do
    FileUtils.rm_rf(Rails.root.join("tmp/finance_transactional_exports"))
  end

  describe '#run' do
    it 'creates a CSV and ZIP file' do
      travel_to(current_time) do
        exporter.run
      end

      output_dir = Rails.root.join("tmp/finance_transactional_exports")
      csv_files = Dir.glob(File.join(output_dir, '*.csv'))
      zip_files = Dir.glob(File.join(output_dir, '*.zip'))

      expect(csv_files.size).to eq(1)
      expect(zip_files.size).to eq(1)
    end
  end

  describe 'CSV output' do
    subject(:csv_content) do
      travel_to(current_time) do
        exporter.run
      end
      output_dir = Rails.root.join("tmp/finance_transactional_exports")
      csv_file = Dir.glob(File.join(output_dir, '*.csv')).first
      File.read(csv_file)
    end

    it 'contains static meta data' do
      expect(csv_content).to include('Report Title:,Finance Transactional Report')
      expect(csv_content).to include('Criteria:,"Date status changed to ""successful"""')
    end

    it 'contains dynamic meta data (dates)' do
      expect(csv_content).to include('Period Selected:,01/04/2025-09/03/2026')
      expect(csv_content).to include('Run:,15/01/2026 10:30')
    end

    it 'contains headers' do
      expect(csv_content).to include(
        'Month-Year,SOP,Office Name,Jurisdiction Name,Remission Amount,Refund,Decision,Application Type,Application ID,HwF Reference,Decision Date,Fee Amount'
      )
    end

    it 'contains transactional data for applications in the date range' do
      decision_date = start_date + 10.days
      application = create(:application_full_remission, :with_office, :processed_state,
                           business_entity_id: business_entity1.id,
                           fee: 500, decision: 'full', decision_date: decision_date)

      expect(csv_content).to include(application.reference)
      expect(csv_content).to include(business_entity1.sop_code)
    end

    it 'excludes Digital office applications' do
      decision_date = start_date + 10.days
      application = create(:application_full_remission, :processed_state,
                           office: digital_office,
                           business_entity_id: business_entity1.id,
                           fee: 500, decision: 'full', decision_date: decision_date)

      expect(csv_content).not_to include(application.reference)
    end

    it 'excludes applications outside the date range' do
      application = create(:application_full_remission, :with_office, :processed_state,
                           business_entity_id: business_entity1.id,
                           fee: 500, decision: 'full', decision_date: Date.new(2024, 1, 1))

      expect(csv_content).not_to include(application.reference)
    end

    it 'excludes non-processed applications' do
      decision_date = start_date + 10.days
      application = create(:application_full_remission, :with_office,
                           business_entity_id: business_entity1.id,
                           fee: 500, decision: 'full', decision_date: decision_date,
                           state: Application.states[:waiting_for_evidence])

      expect(csv_content).not_to include(application.reference)
    end

    it 'excludes applications without part or full decisions' do
      decision_date = start_date + 10.days
      application = create(:application_full_remission, :with_office, :processed_state,
                           business_entity_id: business_entity1.id,
                           fee: 500, decision: 'none', decision_date: decision_date)

      expect(csv_content).not_to include(application.reference)
    end
  end

  describe 'output matches FinanceTransactionalReportBuilder' do
    let(:decision_date) { start_date + 10.days }

    before do
      create(:application_full_remission, :with_office, :processed_state,
             business_entity_id: business_entity1.id,
             fee: 500, decision: 'full', decision_date: decision_date)
      create(:application_full_remission, :with_office, :processed_state,
             business_entity_id: business_entity2.id,
             fee: 300, decision: 'part', decision_date: decision_date + 5.days)
    end

    it 'produces the same data rows as the builder' do
      travel_to(current_time) do
        exporter.run

        start_date_hash = { day: start_date.day, month: start_date.month, year: start_date.year }
        end_date_hash = { day: end_date.day, month: end_date.month, year: end_date.year }
        builder_csv = FinanceTransactionalReportBuilder.new(start_date_hash, end_date_hash).to_csv

        output_dir = Rails.root.join("tmp/finance_transactional_exports")
        exporter_csv = File.read(Dir.glob(File.join(output_dir, '*.csv')).first)

        builder_data_lines = builder_csv.lines.drop(6).map(&:strip).reject(&:empty?)
        exporter_data_lines = exporter_csv.lines.drop(6).map(&:strip).reject(&:empty?)

        expect(exporter_data_lines).to eq(builder_data_lines)
      end
    end
  end
end
