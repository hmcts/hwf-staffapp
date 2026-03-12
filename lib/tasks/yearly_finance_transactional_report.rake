namespace :reports do
  desc 'Generate yearly finance transactional report as CSV and zip it'
  task :yearly_finance_transactional => :environment do
    exporter = YearlyFinanceTransactionalExporter.new
    exporter.run
  end
end

class YearlyFinanceTransactionalExporter
  require 'csv'
  require 'zip'
  require 'fileutils'

  BATCH_SIZE = 1000

  def csv_fields
    FinanceTransactionalReportBuilder::CSV_FIELDS
  end

  def initialize
    @start_date = Date.new(2025, 4, 1)
    @end_date = Date.new(2026, 3, 9)
    @output_dir = Rails.root.join("tmp/finance_transactional_exports")
    FileUtils.mkdir_p(@output_dir)
  end

  def run
    log "Generating Finance Transactional Report"
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
    fields = csv_fields

    record_count = File.open(filepath, 'w') do |file|
      write_csv_headers(file, fields)
      write_csv_data(file, fields)
    end

    log_completion(record_count, filepath, start_time)
    filepath
  end

  def csv_filepath
    filename = "finance_transactional_#{@start_date}_to_#{@end_date}.csv"
    File.join(@output_dir, filename)
  end

  def write_csv_headers(file, fields)
    file.write(meta_data_csv)
    file.write(CSV.generate_line(['']))
    file.write(CSV.generate_line(fields.values))
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def write_csv_data(file, fields)
    record_count = 0
    offset = 0

    loop do
      batch = report_query.offset(offset).limit(BATCH_SIZE).to_a
      break if batch.empty?

      batch.each do |application|
        row = Views::Reports::FinanceTransactionalReportDataRow.new(application)
        file.write(CSV.generate_line(fields.keys.map { |attr| format_field(row, attr) }))
        record_count += 1
      end

      log "  Processed #{record_count} records..." if (record_count % 10_000).zero?

      offset += BATCH_SIZE
      ActiveRecord::Base.connection.clear_query_cache
    end

    record_count
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def report_query
    Application.
      includes(:detail, :office, :business_entity).
      includes(business_entity: :jurisdiction).
      where(decision: ['part', 'full']).
      where(decision_date: @start_date.beginning_of_day..@end_date.end_of_day).
      where(state: Application.states[:processed]).
      where("offices.name NOT IN ('Digital')").
      order(Arel.sql('decision_date::timestamp::date ASC')).
      order(Arel.sql('business_entities.sop_code ASC'))
  end

  def log_completion(record_count, filepath, start_time)
    elapsed = (Time.zone.now - start_time).round(2)
    file_size_mb = (File.size(filepath) / 1024.0 / 1024.0).round(2)
    log "  ✓ #{record_count} records exported (#{file_size_mb} MB) in #{elapsed}s"
  end

  def log(message)
    puts message unless Rails.env.test?
  end

  def format_field(row, attr)
    if attr == :decision_date
      row.send(attr).present? ? row.send(attr).to_fs(:default) : 'N/A'
    else
      value = row.send(attr)
      value.nil? ? 'N/A' : value
    end
  end

  def meta_data_csv
    period = "#{@start_date.to_fs(:default)}-#{@end_date.to_fs(:default)}"
    run_time = Time.zone.now

    CSV.generate do |csv|
      csv << ['Report Title:', 'Finance Transactional Report']
      csv << ['Criteria:', 'Date status changed to "successful"']
      csv << ['Period Selected:', period]
      csv << ['Run:', run_time.to_fs(:default)]
    end
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
