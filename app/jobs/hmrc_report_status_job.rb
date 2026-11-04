# Mirrors DwpReportStatusJob for the HMRC checker - see CHANGELOG.md.
class HmrcReportStatusJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    log_task_run
    run_hmrc_check
  end

  private

  def run_hmrc_check
    send_email_notifications if HmrcMonitor.new.state == 'offline'
  end

  def send_email_notifications
    NotifyMailer.hmrc_is_down_notifier.deliver_now
    log_notification
  end

  def log_task_run
    tc = ApplicationInsights::TelemetryClient.new ENV.fetch('AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY', nil)
    tc.track_event("Running HMRC status check at #{Time.zone.now.to_fs(:db)}")
    tc.flush
  end

  def log_notification
    tc = ApplicationInsights::TelemetryClient.new ENV.fetch('AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY', nil)
    tc.track_event("Sending HMRC status is offline notication at #{Time.zone.now.to_fs(:db)}")
    tc.flush
  end

end
