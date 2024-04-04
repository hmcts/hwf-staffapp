class AbandonedApplicationPurgeJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    log_task_run('Running')
    purge_abandoned_applications
    log_task_run('Finished')
  end

  private

  def purge_abandoned_applications
    abandoned_applications.each(&:really_destroy!)
  end

  def abandoned_applications
    Application.where(state: 0).where('created_at <= ?', 28.days.ago)
  end

  def log_task_run(event)
    tc = ApplicationInsights::TelemetryClient.new ENV.fetch('AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY', nil)
    tc.track_event("#{event} Abandoned application purge data script #{Time.zone.now.to_fs(:short)}")
    tc.flush
  end

end
