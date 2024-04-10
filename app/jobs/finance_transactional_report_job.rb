class FinanceTransactionalReportJob < ApplicationJob
  queue_as :default

  def perform(args)
    @user = User.find(args[:user_id])
    @from_date = args[:from]
    @to_date = args[:to]
    @filters = args[:filters] || {}
    log_task_run('start')
    extract_finance_transactional_report
    log_task_run('end')
  end

  private

  def extract_finance_transactional_report
    @export = FinanceTransactionalReportBuilder.new(@from_date, @to_date, @filters)
    @export.to_zip

    store_zip_file
    send_email_notifications
  rescue StandardError => e
    Sentry.with_scope do |scope|
      scope.set_tags(task: "financial_export")
      Sentry.capture_message(e.message)
    end
    Rails.logger.debug { "Error in financial_export export task: #{e.message}" }
  end

  def store_zip_file
    @storage = ExportFileStorage.new(user: @user, name: 'finance_transactional')
    @storage.export_file.attach(io: File.open(@export.zipfile_path), filename: 'financial_export.zip')
    @storage.save
  end

  def send_email_notifications
    NotifyMailer.file_report_ready(@user, @storage.id).deliver_now
    log_notification
  end

  def log_task_run(event)
    tc = ApplicationInsights::TelemetryClient.new ENV.fetch('AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY', nil)
    tc.track_event("Running Finance Transactional #{event} at #{Time.zone.now.to_fs(:db)}")
    tc.flush
  end

  def log_notification
    tc = ApplicationInsights::TelemetryClient.new ENV.fetch('AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY', nil)
    tc.track_event("Sending Finance Transactional email notification at #{Time.zone.now.to_fs(:db)}")
    tc.flush
  end

end
