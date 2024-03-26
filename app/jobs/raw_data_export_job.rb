class RawDataExportJob < ApplicationJob
  queue_as :default

  def perform(args)
    @user = User.find(args[:user_id])
    @from_date = args[:from]
    @to_date = args[:to]
    extract_raw_data
    log_task_run
  end

  private

  def extract_raw_data
    @raw_export = Views::Reports::RawDataExport.new(@from_date, @to_date)
    @raw_export.to_zip

    store_zip_file
    send_email_notifications
  rescue StandardError => e
    Sentry.with_scope do |scope|
      scope.set_tags(task: "raw_data_export")
      Sentry.capture_message(e.message)
    end
    Rails.logger.debug { "Error in raw_data export task: #{e.message}" }
  end

  def store_zip_file
    @storage = ExportFileStorage.new(user: @user)
    @storage.export_file.attach(io: File.open(@raw_export.zipfile_path), filename: 'test_raw_data.zip')
    @storage.save
  end


  def send_email_notifications
    NotifyMailer.raw_data_extract_ready(@user, @storage.id).deliver_now
    log_notification
  end

  def log_task_run
    tc = ApplicationInsights::TelemetryClient.new ENV.fetch('AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY', nil)
    tc.track_event("Running RawDataExport at #{Time.zone.now.to_fs(:db)}")
    tc.flush
  end

  def log_notification
    tc = ApplicationInsights::TelemetryClient.new ENV.fetch('AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY', nil)
    tc.track_event("Sending RawDataExport email notification at #{Time.zone.now.to_fs(:db)}")
    tc.flush
  end

end