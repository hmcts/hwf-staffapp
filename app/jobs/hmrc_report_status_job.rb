# Mirrors DwpReportStatusJob for the HMRC checker - see CHANGELOG.md.
# Uses the real HmrcMonitor state, never the admin HMRC message switch (RST-8807).
class HmrcReportStatusJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    log_event("Running HMRC status check at #{Time.zone.now.to_fs(:db)}")
    run_hmrc_check
  end

  private

  def run_hmrc_check
    StatusNotificationSchedule.new('hmrc', HmrcMonitor.new.state).run do |email|
      send_email(email)
    end
  rescue StandardError => e
    # e.g. a missing Notify template ID: report it and let the next check retry
    Sentry.capture_exception(e)
    log_event("HMRC status email failed at #{Time.zone.now.to_fs(:db)}: #{e.message}")
  end

  def send_email(email)
    if email == :down
      NotifyMailer.hmrc_is_down_notifier.deliver_now
      log_event("Sending HMRC status is offline notication at #{Time.zone.now.to_fs(:db)}")
    else
      NotifyMailer.hmrc_is_up_notifier.deliver_now
      log_event("Sending HMRC status is online notification at #{Time.zone.now.to_fs(:db)}")
    end
  end

  def log_event(message)
    tc = ApplicationInsights::TelemetryClient.new ENV.fetch('AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY', nil)
    tc.track_event(message)
    tc.flush
  end
end
