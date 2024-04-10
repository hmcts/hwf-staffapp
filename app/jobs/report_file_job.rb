class ReportFileJob < ApplicationJob

  private

  def report_error(err_caught, error_context)
    Sentry.with_scope do |scope|
      scope.set_tags(task: error_context)
      Sentry.capture_message(err_caught.message)
    end
    Rails.logger.debug { "Error in #{error_context} export task: #{err_caught.message}" }
  end

  def store_zip_file(file_name)
    @storage = ExportFileStorage.new(user: @user, name: file_name)
    @storage.export_file.attach(io: File.open(@export.zipfile_path), filename: "#{file_name}.zip")
    @storage.save
  end

  def send_email_notifications
    NotifyMailer.file_report_ready(@user, @storage.id).deliver_now
    log_notification
  end

  def log_task_run(event, name)
    tc = ApplicationInsights::TelemetryClient.new ENV.fetch('AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY', nil)
    tc.track_event("Running #{name} #{event} at #{Time.zone.now.to_fs(:db)}")
    tc.flush
  end

  def log_notification
    tc = ApplicationInsights::TelemetryClient.new ENV.fetch('AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY', nil)
    tc.track_event("Sending #{@task_name} email notification at #{Time.zone.now.to_fs(:db)}")
    tc.flush
  end

end
