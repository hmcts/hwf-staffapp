namespace :reports do
  desc 'Generate yearly raw data export as CSV and zip it'
  task :yearly_raw_data => :environment do
    exporter = YearlyRawDataExporter.new
    exporter.run
  end
end

# rubocop:disable Metrics/ClassLength
class YearlyRawDataExporter
  require 'csv'
  require 'zip'
  require 'fileutils'

  BATCH_SIZE = 1000

  def initialize
    @start_date = Date.new(2025, 4, 1)
    @end_date = Date.new(2026, 3, 9)
    @output_dir = Rails.root.join("tmp/raw_data_exports")
    FileUtils.mkdir_p(@output_dir)
  end

  def run
    log "Generating Raw Data Export"
    log "Period: #{@start_date} to #{@end_date}"
    log "=" * 60

    csv_filepath = generate_csv
    zip_filepath = zip_file(csv_filepath)

    log "\n✓ Done!"
    log "CSV: #{csv_filepath}"
    log "ZIP: #{zip_filepath}"
  end

  private

  def generate_csv
    filepath = csv_filepath
    start_time = Time.zone.now

    record_count = File.open(filepath, 'w') do |file|
      file.write(CSV.generate_line(export_helper.class::HEADERS))
      write_csv_data(file)
    end

    log_completion(record_count, filepath, start_time)
    filepath
  end

  def csv_filepath
    filename = "raw_data_#{@start_date}_to_#{@end_date}.csv"
    File.join(@output_dir, filename)
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def write_csv_data(file)
    record_count = 0
    offset = 0
    attributes = export_helper.class::ATTRIBUTES

    loop do
      sql = "#{base_sql} ORDER BY applications.id ASC LIMIT #{BATCH_SIZE} OFFSET #{offset}"
      rows = ActiveRecord::Base.connection.exec_query(sql).to_a.map(&:with_indifferent_access)
      break if rows.empty?

      rows.each do |row|
        file.write(CSV.generate_line(attributes.map { |attr| export_helper.process_row(row, attr) }))
        record_count += 1
      end

      log "  Processed #{record_count} records..." if (record_count % 10_000).zero?

      offset += BATCH_SIZE
      ActiveRecord::Base.connection.clear_query_cache
    end

    record_count
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def export_helper
    @export_helper ||= begin
      start_hash = { day: @start_date.day, month: @start_date.month, year: @start_date.year }
      end_hash = { day: @end_date.day, month: @end_date.month, year: @end_date.year }
      Views::Reports::RawDataExport.new(start_hash, end_hash)
    end
  end

  def base_sql
    @base_sql ||= build_base_sql
  end

  # rubocop:disable Metrics/MethodLength
  def build_base_sql
    date_from = @start_date.beginning_of_day.strftime('%Y-%m-%d %H:%M:%S')
    date_to = @end_date.end_of_day.strftime('%Y-%m-%d %H:%M:%S')

    <<~SQL.squish
      SELECT
        applications.id,
        applications.reference,
        applications.children_age_band,
        details.fee,
        details.form_name,
        details.refund,
        details.statement_signed_by,
        applications.application_type,
        applications.income,
        applications.income_period,
        applications.children,
        applications.decision,
        COALESCE(applications.amount_to_pay, 0) as amount_to_pay,
        applications.decision_cost,
        applicants.married,
        applicants.partner_ni_number,
        applicants.partner_last_name,
        applications.income_min_threshold_exceeded,
        applications.income_max_threshold_exceeded,
        applicants.ni_number,
        applicants.ho_number,
        offices.name AS name,
        details.emergency_reason IS NOT NULL AS emergency,
        jurisdictions.name AS jurisdiction,
        business_entities.sop_code AS sop_code,
        part_payments.outcome AS pp_outcome,
        CASE WHEN applications.reference LIKE 'HWF%' THEN 'digital' ELSE 'paper' END AS source,
        CASE WHEN de.id IS NULL THEN false ELSE true END AS granted,
        CASE WHEN beo.id IS NULL THEN 'N/A'
             WHEN beo.correct = TRUE THEN 'Yes'
             WHEN beo.correct = FALSE THEN 'No'
        END AS benefits_granted,
        CASE WHEN ec.id IS NULL THEN false ELSE true END AS evidence_checked,
        CASE WHEN savings.max_threshold_exceeded = TRUE then 'High'
             WHEN savings.max_threshold_exceeded = FALSE AND savings.min_threshold_exceeded = TRUE THEN 'Medium'
             WHEN savings.max_threshold_exceeded = FALSE THEN 'Low'
             WHEN savings.max_threshold_exceeded IS NULL AND savings.min_threshold_exceeded = FALSE THEN 'Low'
             WHEN savings.max_threshold_exceeded IS NULL AND savings.min_threshold_exceeded = TRUE THEN 'High'
             ELSE 'N/A'
        END AS capital,
        CASE WHEN savings.passed = FALSE then 'Yes'
            WHEN savings.passed = TRUE then 'No'
            ELSE 'N/A' END AS saving_failed,
        CASE WHEN part_payments.outcome = 'return' THEN 'return'
             WHEN part_payments.outcome = 'none' THEN 'false'
             WHEN part_payments.outcome = 'part' THEN 'true' ELSE 'N/A' END AS part_payment_outcome,
        part_payments.outcome AS pp_outcome,
        CASE WHEN savings.amount >= 16000 THEN NULL
             ELSE savings.amount
        END AS savings_amount,
        CASE WHEN ec.income_check_type = 'paper' THEN ec.completed_at ELSE NULL END as manual_process_date,
        savings.over_66 AS over_66,
        details.case_number AS case_number,
        oa.postcode AS postcode,
        applicants.date_of_birth AS date_of_birth,
        details.date_received AS date_received,
        applications.decision_date AS decision_date,
        details.date_fee_paid AS date_fee_paid,
        applications.completed_at AS application_processed_date,
        oa.created_at AS date_submitted_online,
        details.statement_signed_by AS statement_signed_by,
        details.calculation_scheme AS calculation_scheme,
        ec.income AS check_income,
        ec.amount_to_pay AS evidence_check_amount_to_pay,
        ec.outcome AS ev_check_outcome,
        CASE WHEN applicants.partner_ni_number IS NULL THEN 'false'
             WHEN applicants.partner_ni_number = '' THEN 'false'
             WHEN applicants.partner_ni_number IS NOT NULL THEN 'true'
             END AS partner_ni,
        CASE WHEN applicants.partner_last_name IS NULL THEN 'false'
             WHEN applicants.partner_last_name IS NOT NULL THEN 'true'
             END AS partner_name,
        CASE WHEN applications.income <= 101 THEN 'true'
             WHEN applications.income > 101 THEN 'false'
             ELSE 'N/A' END AS low_income_declared,
        ec.check_type as db_evidence_check_type,
        ec.income_check_type as db_income_check_type,
        ec.hmrc_income_used as hmrc_total_income,
        CASE WHEN ec.check_type = 'random' AND ec.income_check_type = 'paper' AND hc.hc_id IS NULL then 'Manual NumberRule'
        WHEN ec.check_type = 'flag' AND ec.income_check_type = 'paper' AND hc.hc_id IS NULL then 'Manual NIFlag'
        WHEN ec.check_type = 'ni_exist' AND ec.income_check_type = 'paper' AND hc.hc_id IS NULL then 'Manual NIDuplicate'
        WHEN ec.check_type = 'low_income' AND ec.income_check_type = 'paper' AND hc.hc_id IS NULL THEN 'Manual LowIncome'
        WHEN ec.check_type = 'random' AND ec.income_check_type = 'hmrc' then 'HMRC NumberRule'
        WHEN ec.check_type = 'flag' AND ec.income_check_type = 'hmrc' then 'HMRC NIFlag'
        WHEN ec.check_type = 'ni_exist' AND ec.income_check_type = 'hmrc' then 'HMRC NIDuplicate'
        WHEN ec.check_type = 'low_income' AND ec.income_check_type = 'hmrc' THEN 'HMRC LowIncome'
        WHEN ec.check_type = 'flag' AND ec.income_check_type = 'paper' AND hc.hc_id IS NOT NULL then 'ManualAfterHMRC'
        WHEN ec.check_type = 'random' AND ec.income_check_type = 'paper' AND hc.hc_id IS NOT NULL then 'ManualAfterHMRC'
        WHEN ec.check_type = 'low_income' AND ec.income_check_type = 'paper' AND hc.hc_id IS NOT NULL THEN 'ManualAfterHMRC'
        ELSE NULL
        END AS evidence_check_type,
        CASE WHEN hc.hc_id IS NULL then NULL
          WHEN hc.hc_id IS NOT NULL AND hc.error_response IS NULL then 'Yes'
          WHEN hc.hc_id IS NOT NULL AND hc.error_response IS NOT NULL then 'No'
          ELSE NULL
        END AS hmrc_response,
        hc.error_response as hmrc_errors,
        CASE WHEN hc.hc_id IS NULL then NULL
          WHEN hc.hc_id IS NOT NULL AND ec.completed_at IS NOT NULL then 'Yes'
          WHEN hc.hc_id IS NOT NULL AND ec.completed_at IS NULL then 'No'
          ELSE NULL
        END AS complete_processing,
        CASE WHEN hc.additional_income IS NULL then NULL
          WHEN hc.additional_income IS NOT NULL AND ec.income_check_type = 'paper' then NULL
          WHEN hc.additional_income IS NOT NULL AND ec.income_check_type = 'hmrc'
            AND hc.additional_income > 0 then hc.additional_income
          ELSE NULL
        END as additional_income,
        CASE WHEN ec.income IS NULL then applications.income
          WHEN ec.completed_at IS NOT NULL then ec.income
          ELSE NULL
        END as income_processed,
        hc.request_params as hmrc_request_date_range
      FROM applications
      INNER JOIN applicants ON applicants.application_id = applications.id
      INNER JOIN business_entities ON business_entities.id = applications.business_entity_id
      INNER JOIN details ON details.application_id = applications.id
      INNER JOIN jurisdictions ON jurisdictions.id = details.jurisdiction_id
      LEFT JOIN offices ON offices.id = applications.office_id
      LEFT JOIN decision_overrides de ON de.application_id = applications.id
      LEFT JOIN benefit_overrides beo ON beo.application_id = applications.id
      LEFT JOIN evidence_checks ec ON ec.application_id = applications.id
      LEFT JOIN online_applications oa ON oa.id = applications.online_application_id
      LEFT JOIN savings ON savings.application_id = applications.id
      LEFT JOIN part_payments ON part_payments.application_id = applications.id
      LEFT JOIN (
        SELECT id as hc_id, income as hc_income, request_params, tax_credit, additional_income,
        error_response, evidence_check_id, created_at, row_number() over
        (partition by evidence_check_id order by created_at desc)
        as row_number from hmrc_checks
      ) hc ON ec.id = hc.evidence_check_id AND (hc.row_number = 1 OR hc.row_number IS NULL)
      WHERE offices.name NOT IN ('Digital', 'HMCTS HQ Team')
        AND applications.decision_date >= '#{date_from}'
        AND applications.decision_date <= '#{date_to}'
        AND applications.state = #{Application.states[:processed]}
    SQL
  end
  # rubocop:enable Metrics/MethodLength

  def log_completion(record_count, filepath, start_time)
    elapsed = (Time.zone.now - start_time).round(2)
    file_size_mb = (File.size(filepath) / 1024.0 / 1024.0).round(2)
    log "  ✓ #{record_count} records exported (#{file_size_mb} MB) in #{elapsed}s"
  end

  def log(message)
    puts message unless Rails.env.test?
  end

  def zip_file(csv_filepath)
    zip_filename = "#{File.basename(csv_filepath, '.csv')}.zip"
    zip_filepath = File.join(@output_dir, zip_filename)

    FileUtils.rm_f(zip_filepath)

    Zip::File.open(zip_filepath, create: true) do |zipfile|
      zipfile.add(File.basename(csv_filepath), csv_filepath)
    end

    zip_filepath
  end
end
# rubocop:enable Metrics/ClassLength
