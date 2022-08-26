class PersonalDataPurgeJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    app_insights_log
    purge_old_personal_data
  end

  private

  def purge_old_personal_data
    PersonalDataPurge.new(old_personal_data).purge!
    app_insights_log_end
  end

  def old_personal_data
    @applications ||= Application.where('completed_at < ?', Settings.personal_data_purge.years_ago.years.ago)
  end

  def app_insights_log
    tc = ApplicationInsights::TelemetryClient.new ENV.fetch('AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY', nil)
    tc.track_event("Running Personal data purge script: #{Time.zone.now.to_fs(:db)}")
    tc.flush
  end

  def app_insights_log_end
    time = Time.zone.now.to_fs(:db)
    count = @applications.count
    tc = ApplicationInsights::TelemetryClient.new ENV.fetch('AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY', nil)
    tc.track_event("Finished personal data purge script: #{time}, applications affected: #{count}")
    tc.flush
  end

end
