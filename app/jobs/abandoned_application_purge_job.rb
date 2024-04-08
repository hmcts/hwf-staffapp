class AbandonedApplicationPurgeJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    log_task_run('Running')
    purge_abandoned_applications
    log_task_run('Finished')
  end

  private

  def purge_abandoned_applications
    abandoned_applications.each do |application|
      application.really_destroy!
    rescue StandardError => e
      Sentry.capture_message(e.message,
                             extra: { application_id: application.id, event: 'Purge abandoned applications' })
      BenefitCheck.where(application_id: application.id, applicationable_id: nil,
                         applicationable_type: nil).last.destroy
    end
  end

  def abandoned_applications
    Application.where(state: 0).where('created_at <= ?', 28.days.ago).with_deleted
  end

  def log_task_run(event)
    tc = ApplicationInsights::TelemetryClient.new ENV.fetch('AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY', nil)
    tc.track_event("#{event} Abandoned application purge data script #{Time.zone.today}")
    tc.flush
  end

end
