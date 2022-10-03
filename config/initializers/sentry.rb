Sentry.init do |config|
  config.transport.ssl_verification = Settings.sentry.ssl_verification == true
  config.rails.report_rescued_exceptions = true
  config.breadcrumbs_logger = [:active_support_logger]
  config.dsn = Settings.sentry.dsn
end
