class PersonalDataPurgeJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    app_insights_log
    purge_old_personal_data
    purge_old_personal_data_online_only
  end

  private

  def purge_old_personal_data
    PersonalDataPurge.new(old_personal_data).purge! if old_personal_data.present?
    app_insights_log_end("applications affected: #{@applications.count}")
  end

  # online application could exist without application, we need to purge them too
  def purge_old_personal_data_online_only
    PersonalDataPurge.new(online_applications).purge_online_only! if online_applications.present?
    app_insights_log_end("online applications affected: #{@online_applications.count}")
  end

  def online_applications
    years = Settings.personal_data_purge.years_ago.years.ago

    @online_applications ||= OnlineApplication.where('created_at < ?', years).reject do |online_applicaiton|
      online_applicaiton.linked_application.present?
    end
  end

  def old_personal_data
    @applications ||= Application.where('created_at < ?', Settings.personal_data_purge.years_ago.years.ago)
  end

  def app_insights_log
    tc = ApplicationInsights::TelemetryClient.new ENV.fetch('AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY', nil)
    tc.track_event("Running Personal data purge script: #{Time.zone.now.to_fs(:db)}")
    tc.flush
  end

  def app_insights_log_end(message)
    time = Time.zone.now.to_fs(:db)
    tc = ApplicationInsights::TelemetryClient.new ENV.fetch('AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY', nil)
    tc.track_event("Finished personal data purge script: #{time}, #{message}")
    tc.flush
  end

end
