class DwpReportStatusJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    log_task_run
    run_dwp_check
  end

  private

  def run_dwp_check
    send_email_notifications if DwpMonitor.new.state == 'offline'
  end

  def send_email_notifications
    ApplicationMailer.dwp_is_down_notifier.deliver_now
    log_notification
  end

  def log_task_run
    tc = ApplicationInsights::TelemetryClient.new ENV.fetch('AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY', nil)
    tc.track_event("Running DWP status check at #{Time.zone.now.to_fs(:db)}")
    tc.flush
  end

  def log_notification
    tc = ApplicationInsights::TelemetryClient.new ENV.fetch('AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY', nil)
    tc.track_event("Sending DWP status is offline notication at #{Time.zone.now.to_fs(:db)}")
    tc.flush
  end

end
