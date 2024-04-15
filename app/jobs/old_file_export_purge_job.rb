class OldFileExportPurgeJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    log_task_run('Running')
    purge_old_exports
    log_task_run('Finished')
  end

  private

  def purge_old_exports
    old_exports.each do |storage|
      storage.destroy
    rescue StandardError => e
      Sentry.capture_message(e.message,
                             extra: { application_id: storage.id, event: 'Purge old files' })
    end
  end

  def old_exports
    ExportFileStorage.where('created_at <= ?', 1.day.ago)
  end

  def log_task_run(event)
    tc = ApplicationInsights::TelemetryClient.new ENV.fetch('AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY', nil)
    tc.track_event("#{event} old export files purge script #{Time.zone.today}")
    tc.flush
  end

end
