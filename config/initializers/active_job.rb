Rails.application.config.tap do |config|
  config.active_job.queue_adapter = Settings.active_job.enabled ? :delayed_job : :inline
end
