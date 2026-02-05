# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/LetSetup
RSpec.describe Views::Reports::PowerBiNewExport do
  subject(:report) { described_class.new(start_date, end_date) }

  let(:office) { create(:office) }
  let(:business_entity) { create(:business_entity) }
  let(:start_date) { (Time.zone.today - 1.month).to_s }
  let(:end_date) { (Time.zone.today + 1.month).to_s }

  after do
    FileUtils.rm_f(report.zipfile_path) if report.zipfile_path && File.exist?(report.zipfile_path)
  end

  describe '#export1 (processed only by decision_date)' do
    context 'with processed application' do
      let!(:application) do
        create(:application_full_remission, :processed_state,
               office: office, business_entity: business_entity, decision_date: Time.zone.now)
      end

      it 'generates a zip file' do
        report.export1
        expect(File.exist?(report.zipfile_path)).to be true
      end

      it 'includes processed applications' do
        report.export1
        csv_content = read_csv_from_zip
        row = csv_content.find { |r| r['id'].to_i == application.id }

        expect(row).to be_present
      end
    end

    context 'with waiting_for_evidence application' do
      let!(:application) do
        create(:application_full_remission, :waiting_for_evidence_state,
               office: office, business_entity: business_entity, decision_date: Time.zone.now)
      end

      it 'excludes waiting_for_evidence applications' do
        report.export1
        csv_content = read_csv_from_zip

        expect(csv_content).to be_empty
      end
    end

    context 'with created application' do
      let!(:application) do
        create(:application_full_remission,
               office: office, business_entity: business_entity, decision_date: Time.zone.now)
      end

      it 'excludes created applications' do
        report.export1
        csv_content = read_csv_from_zip

        expect(csv_content).to be_empty
      end
    end
  end

  describe '#export2 (all except created by created_at)' do
    context 'with processed application' do
      let!(:application) do
        create(:application_full_remission, :processed_state,
               office: office, business_entity: business_entity, created_at: Time.zone.now)
      end

      it 'includes processed applications' do
        report.export2
        csv_content = read_csv_from_zip
        row = csv_content.find { |r| r['id'].to_i == application.id }

        expect(row).to be_present
      end
    end

    context 'with waiting_for_evidence application' do
      let!(:application) do
        create(:application_full_remission, :waiting_for_evidence_state,
               office: office, business_entity: business_entity, created_at: Time.zone.now)
      end

      it 'includes waiting_for_evidence applications' do
        report.export2
        csv_content = read_csv_from_zip
        row = csv_content.find { |r| r['id'].to_i == application.id }

        expect(row).to be_present
      end
    end

    context 'with waiting_for_part_payment application' do
      let!(:application) do
        create(:application_full_remission, :waiting_for_part_payment_state,
               office: office, business_entity: business_entity, created_at: Time.zone.now)
      end

      it 'includes waiting_for_part_payment applications' do
        report.export2
        csv_content = read_csv_from_zip
        row = csv_content.find { |r| r['id'].to_i == application.id }

        expect(row).to be_present
      end
    end

    context 'with created application' do
      let!(:application) do
        create(:application_full_remission,
               office: office, business_entity: business_entity, created_at: Time.zone.now)
      end

      it 'excludes created applications' do
        report.export2
        csv_content = read_csv_from_zip

        expect(csv_content).to be_empty
      end
    end
  end

  describe '#export3 (waiting states only by created_at)' do
    context 'with waiting_for_evidence application' do
      let!(:application) do
        create(:application_full_remission, :waiting_for_evidence_state,
               office: office, business_entity: business_entity, created_at: Time.zone.now)
      end

      it 'generates a zip file' do
        report.export3
        expect(File.exist?(report.zipfile_path)).to be true
      end

      it 'includes waiting_for_evidence applications' do
        report.export3
        csv_content = read_csv_from_zip
        row = csv_content.find { |r| r['id'].to_i == application.id }

        expect(row).to be_present
      end
    end

    context 'with waiting_for_part_payment application' do
      let!(:application) do
        create(:application_full_remission, :waiting_for_part_payment_state,
               office: office, business_entity: business_entity, created_at: Time.zone.now)
      end

      it 'includes waiting_for_part_payment applications' do
        report.export3
        csv_content = read_csv_from_zip
        row = csv_content.find { |r| r['id'].to_i == application.id }

        expect(row).to be_present
      end
    end

    context 'with processed application' do
      let!(:application) do
        create(:application_full_remission, :processed_state,
               office: office, business_entity: business_entity, created_at: Time.zone.now)
      end

      it 'excludes processed applications' do
        report.export3
        csv_content = read_csv_from_zip

        expect(csv_content).to be_empty
      end
    end

    context 'with created application' do
      let!(:application) do
        create(:application_full_remission,
               office: office, business_entity: business_entity, created_at: Time.zone.now)
      end

      it 'excludes created applications' do
        report.export3
        csv_content = read_csv_from_zip

        expect(csv_content).to be_empty
      end
    end
  end

  describe 'excluded offices' do
    let!(:digital_office) { create(:office, name: 'Digital') }
    let!(:hmcts_office) { create(:office, name: 'HMCTS HQ Team') }

    context 'with application from Digital office' do
      let!(:application) do
        create(:application_full_remission, :processed_state,
               office: digital_office, business_entity: business_entity,
               decision_date: Time.zone.now, created_at: Time.zone.now)
      end

      it 'excludes from export1' do
        report.export1
        csv_content = read_csv_from_zip
        expect(csv_content).to be_empty
      end

      it 'excludes from export2' do
        report.export2
        csv_content = read_csv_from_zip
        expect(csv_content).to be_empty
      end
    end

    context 'with application from HMCTS HQ Team office' do
      let!(:application) do
        create(:application_full_remission, :processed_state,
               office: hmcts_office, business_entity: business_entity,
               decision_date: Time.zone.now, created_at: Time.zone.now)
      end

      it 'excludes from export1' do
        report.export1
        csv_content = read_csv_from_zip
        expect(csv_content).to be_empty
      end

      it 'excludes from export2' do
        report.export2
        csv_content = read_csv_from_zip
        expect(csv_content).to be_empty
      end
    end
  end

  describe 'evidence check data' do
    let!(:application) do
      create(:application_part_remission,
             office: office, business_entity: business_entity, created_at: Time.zone.now,
             income: 500, state: :waiting_for_evidence)
    end
    let!(:evidence_check) do
      create(:evidence_check, application: application,
                              income: 1200,
                              outcome: 'part',
                              check_type: 'random',
                              income_check_type: 'hmrc',
                              hmrc_income_used: 1150.50,
                              completed_at: 1.day.ago)
    end

    it 'includes evidence check income as post evidence income' do
      report.export2
      csv_content = read_csv_from_zip
      row = csv_content.find { |r| r['id'].to_i == application.id }

      expect(row['post evidence income']).to eq('1200')
    end

    it 'includes evidence check outcome' do
      report.export2
      csv_content = read_csv_from_zip
      row = csv_content.find { |r| r['id'].to_i == application.id }

      expect(row['evidence check outcome']).to eq('part')
    end

    it 'includes DB evidence check type' do
      report.export2
      csv_content = read_csv_from_zip
      row = csv_content.find { |r| r['id'].to_i == application.id }

      expect(row['DB evidence check type']).to eq('random')
    end

    it 'includes DB income check type' do
      report.export2
      csv_content = read_csv_from_zip
      row = csv_content.find { |r| r['id'].to_i == application.id }

      expect(row['DB income check type']).to eq('hmrc')
    end

    it 'includes HMRC total income' do
      report.export2
      csv_content = read_csv_from_zip
      row = csv_content.find { |r| r['id'].to_i == application.id }

      expect(row['HMRC total income']).to eq('1150.5')
    end

    it 'marks evidence checked as yes' do
      report.export2
      csv_content = read_csv_from_zip
      row = csv_content.find { |r| r['id'].to_i == application.id }

      expect(row['evidence checked?']).to eq('yes')
    end
  end

  describe 'part payment data' do
    let!(:application) do
      create(:application_part_remission, :waiting_for_part_payment_state,
             office: office, business_entity: business_entity, created_at: Time.zone.now)
    end
    let!(:part_payment) do
      create(:part_payment, application: application, outcome: 'part')
    end

    it 'includes part payment outcome' do
      report.export3
      csv_content = read_csv_from_zip
      row = csv_content.find { |r| r['id'].to_i == application.id }

      expect(row['PP outcome']).to eq('part')
    end
  end

  private

  def read_csv_from_zip
    csv_content = nil
    Zip::File.open(report.zipfile_path) do |zip_file|
      zip_file.each do |entry|
        csv_content = CSV.parse(entry.get_input_stream.read, headers: true)
      end
    end
    csv_content
  end
end
# rubocop:enable RSpec/LetSetup
