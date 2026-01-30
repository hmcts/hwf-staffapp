# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/LetSetup
RSpec.describe Views::Reports::PowerBiExportV2 do
  subject(:report) { described_class.new(start_date, end_date) }

  let(:office) { create(:office) }
  let(:business_entity) { create(:business_entity) }
  let(:decision_date) { Time.zone.now }
  let(:start_date) { (Time.zone.today - 1.month).to_s }
  let(:end_date) { (Time.zone.today + 1.month).to_s }

  after do
    # Clean up any generated files
    FileUtils.rm_f(report.zipfile_path) if report.zipfile_path && File.exist?(report.zipfile_path)
  end

  describe '#export' do
    let!(:application) do
      create(:application_full_remission, :processed_state,
             office: office, business_entity: business_entity, decision_date: decision_date)
    end

    it 'generates a zip file' do
      report.export
      expect(File.exist?(report.zipfile_path)).to be true
    end

    it 'returns the zipfile path' do
      result = report.export
      expect(result).to eq(report.zipfile_path.to_s)
    end
  end

  describe 'evidence check data' do
    let!(:application) do
      create(:application_part_remission, :processed_state,
             office: office, business_entity: business_entity, decision_date: decision_date,
             income: 500)
    end
    let(:evidence_check) do
      create(:evidence_check, application: application,
                              income: 1200,
                              outcome: 'part',
                              check_type: 'random',
                              income_check_type: 'hmrc',
                              hmrc_income_used: 1150.50,
                              completed_at: 1.day.ago)
    end

    before { evidence_check }

    it 'includes evidence check income as post evidence income' do
      report.export
      csv_content = read_csv_from_zip
      row = csv_content.find { |r| r['id'].to_i == application.id }

      expect(row['post evidence income']).to eq('1200')
    end

    it 'includes evidence check outcome' do
      report.export
      csv_content = read_csv_from_zip
      row = csv_content.find { |r| r['id'].to_i == application.id }

      expect(row['evidence check outcome']).to eq('part')
    end

    it 'includes DB evidence check type' do
      report.export
      csv_content = read_csv_from_zip
      row = csv_content.find { |r| r['id'].to_i == application.id }

      expect(row['DB evidence check type']).to eq('random')
    end

    it 'includes DB income check type' do
      report.export
      csv_content = read_csv_from_zip
      row = csv_content.find { |r| r['id'].to_i == application.id }

      expect(row['DB income check type']).to eq('hmrc')
    end

    it 'includes HMRC total income' do
      report.export
      csv_content = read_csv_from_zip
      row = csv_content.find { |r| r['id'].to_i == application.id }

      expect(row['HMRC total income']).to eq('1150.5')
    end

    it 'marks evidence checked as yes' do
      report.export
      csv_content = read_csv_from_zip
      row = csv_content.find { |r| r['id'].to_i == application.id }

      expect(row['evidence checked?']).to eq('yes')
    end
  end

  describe 'HMRC check data' do
    let!(:application) do
      create(:application_part_remission, :processed_state,
             office: office, business_entity: business_entity, decision_date: decision_date)
    end
    let(:evidence_check) do
      create(:evidence_check, application: application,
                              check_type: 'flag',
                              income_check_type: 'hmrc',
                              completed_at: 1.day.ago)
    end
    let(:date_range) { { date_range: { from: "1/7/2024", to: "31/7/2024" } } }

    context 'with single HMRC check' do
      let!(:hmrc_check) do
        create(:hmrc_check, evidence_check: evidence_check,
                            created_at: 1.day.ago,
                            request_params: date_range,
                            additional_income: 250,
                            error_response: nil)
      end

      it 'includes HMRC request date range' do
        report.export
        csv_content = read_csv_from_zip
        row = csv_content.find { |r| r['id'].to_i == application.id }

        expect(row['HMRC request date range']).to eq('1/7/2024 - 31/7/2024')
      end

      it 'includes additional income' do
        report.export
        csv_content = read_csv_from_zip
        row = csv_content.find { |r| r['id'].to_i == application.id }

        expect(row['additional income']).to eq('250')
      end

      it 'marks HMRC response as Yes when no error' do
        report.export
        csv_content = read_csv_from_zip
        row = csv_content.find { |r| r['id'].to_i == application.id }

        expect(row['HMRC response?']).to eq('Yes')
      end

      it 'marks complete processing as Yes when evidence check completed' do
        report.export
        csv_content = read_csv_from_zip
        row = csv_content.find { |r| r['id'].to_i == application.id }

        expect(row['complete processing?']).to eq('Yes')
      end

      it 'shows evidence check type as HMRC NIFlag' do
        report.export
        csv_content = read_csv_from_zip
        row = csv_content.find { |r| r['id'].to_i == application.id }

        expect(row['evidence check type']).to eq('HMRC NIFlag')
      end
    end

    context 'with HMRC error response' do
      let!(:hmrc_check) do
        create(:hmrc_check, evidence_check: evidence_check,
                            created_at: 1.day.ago,
                            request_params: date_range,
                            error_response: 'HMRC service unavailable')
      end

      it 'marks HMRC response as No when there is an error' do
        report.export
        csv_content = read_csv_from_zip
        row = csv_content.find { |r| r['id'].to_i == application.id }

        expect(row['HMRC response?']).to eq('No')
      end

      it 'includes HMRC errors' do
        report.export
        csv_content = read_csv_from_zip
        row = csv_content.find { |r| r['id'].to_i == application.id }

        expect(row['HMRC errors']).to eq('HMRC service unavailable')
      end
    end
  end

  describe 'multiple HMRC checks for same evidence check' do
    let!(:application) do
      create(:application_part_remission, :processed_state,
             office: office, business_entity: business_entity, decision_date: decision_date)
    end
    let(:evidence_check) do
      create(:evidence_check, application: application,
                              check_type: 'random',
                              income_check_type: 'hmrc',
                              completed_at: 1.day.ago)
    end

    context 'with multiple retries (same person)' do
      before do
        # First attempt - oldest, should be ignored
        create(:hmrc_check, :applicant,
               evidence_check: evidence_check,
               created_at: 5.days.ago,
               request_params: { date_range: { from: "1/6/2024", to: "30/6/2024" } },
               additional_income: 100,
               error_response: 'First attempt failed')

        # Second attempt - middle, should be ignored
        create(:hmrc_check, :applicant,
               evidence_check: evidence_check,
               created_at: 3.days.ago,
               request_params: { date_range: { from: "1/6/2024", to: "30/6/2024" } },
               additional_income: 150,
               error_response: 'Second attempt failed')

        # Third attempt - most recent, should be used
        create(:hmrc_check, :applicant,
               evidence_check: evidence_check,
               created_at: 1.day.ago,
               request_params: { date_range: { from: "1/7/2024", to: "31/7/2024" } },
               additional_income: 200,
               error_response: nil)
      end

      it 'returns only one row per application' do
        report.export
        csv_content = read_csv_from_zip
        rows = csv_content.select { |r| r['id'].to_i == application.id }

        expect(rows.count).to eq(1)
      end

      it 'uses the most recent HMRC check data' do
        report.export
        csv_content = read_csv_from_zip
        row = csv_content.find { |r| r['id'].to_i == application.id }

        expect(row['additional income']).to eq('200')
        expect(row['HMRC request date range']).to eq('1/7/2024 - 31/7/2024')
        expect(row['HMRC response?']).to eq('Yes')
      end
    end

    context 'with applicant and partner checks (multiple people)' do
      before do
        # Applicant checks - first attempt failed
        create(:hmrc_check, :applicant,
               evidence_check: evidence_check,
               created_at: 4.days.ago,
               request_params: { date_range: { from: "1/6/2024", to: "30/6/2024" } },
               additional_income: 50,
               error_response: 'Applicant first attempt failed')

        # Applicant checks - second attempt succeeded
        create(:hmrc_check, :applicant,
               evidence_check: evidence_check,
               created_at: 3.days.ago,
               request_params: { date_range: { from: "1/7/2024", to: "31/7/2024" } },
               additional_income: 100,
               error_response: nil)

        # Partner checks - first attempt failed
        create(:hmrc_check, :partner,
               evidence_check: evidence_check,
               created_at: 2.days.ago,
               request_params: { date_range: { from: "1/6/2024", to: "30/6/2024" } },
               additional_income: 75,
               error_response: 'Partner first attempt failed')

        # Partner checks - second attempt succeeded (most recent overall)
        create(:hmrc_check, :partner,
               evidence_check: evidence_check,
               created_at: 1.day.ago,
               request_params: { date_range: { from: "1/7/2024", to: "31/7/2024" } },
               additional_income: 150,
               error_response: nil)
      end

      it 'returns only one row per application' do
        report.export
        csv_content = read_csv_from_zip
        rows = csv_content.select { |r| r['id'].to_i == application.id }

        expect(rows.count).to eq(1)
      end

      it 'uses the most recent HMRC check regardless of check_type' do
        report.export
        csv_content = read_csv_from_zip
        row = csv_content.find { |r| r['id'].to_i == application.id }

        # The partner's second check is most recent (1.day.ago)
        expect(row['additional income']).to eq('150')
        expect(row['HMRC response?']).to eq('Yes')
      end
    end

    context 'with 6 HMRC checks (realistic partner scenario with retries)' do
      before do
        # Applicant - 3 attempts
        create(:hmrc_check, :applicant, evidence_check: evidence_check,
                                        created_at: 6.days.ago, additional_income: 10, error_response: 'Error 1')
        create(:hmrc_check, :applicant, evidence_check: evidence_check,
                                        created_at: 5.days.ago, additional_income: 20, error_response: 'Error 2')
        create(:hmrc_check, :applicant, evidence_check: evidence_check,
                                        created_at: 4.days.ago, additional_income: 30, error_response: nil)

        # Partner - 3 attempts
        create(:hmrc_check, :partner, evidence_check: evidence_check,
                                      created_at: 3.days.ago, additional_income: 40, error_response: 'Error 3')
        create(:hmrc_check, :partner, evidence_check: evidence_check,
                                      created_at: 2.days.ago, additional_income: 50, error_response: 'Error 4')
        # This is the most recent one
        create(:hmrc_check, :partner, evidence_check: evidence_check,
                                      created_at: 1.day.ago,
                                      request_params: { date_range: { from: "15/7/2024", to: "15/8/2024" } },
                                      additional_income: 999,
                                      error_response: nil)
      end

      it 'returns only one row per application' do
        report.export
        csv_content = read_csv_from_zip
        rows = csv_content.select { |r| r['id'].to_i == application.id }

        expect(rows.count).to eq(1)
      end

      it 'uses data from the single most recent HMRC check' do
        report.export
        csv_content = read_csv_from_zip
        row = csv_content.find { |r| r['id'].to_i == application.id }

        expect(row['additional income']).to eq('999')
        expect(row['HMRC request date range']).to eq('15/7/2024 - 15/8/2024')
        expect(row['HMRC response?']).to eq('Yes')
      end
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
