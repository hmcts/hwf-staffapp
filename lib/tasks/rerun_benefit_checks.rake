namespace :rerun_benefit_checks do
  desc "if DWPMonitor says it's down rerun failed bc checks to bring it back"
  task perform_job: :environment do
    tc = ApplicationInsights::TelemetryClient.new ENV['AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY']

    if DwpMonitor.new.state == 'offline'
      BenefitCheckRerunJob.perform_now
      tc.track_event("Rake task rerun_benefit_checks - rerun was triggered")
    else
      tc.track_event("Rake task rerun_benefit_checks - no rerun needed")
    end
    tc.flush
  rescue StandardError => e
    tc.track_event("Rake task rerun_benefit_checks - failed: #{e.message}")
    tc.flush
    Rails.logger.error("Rake task rerun_benefit_checks - failed: #{e.message}")
  end
end
