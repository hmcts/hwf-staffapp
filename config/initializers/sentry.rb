EXCLUDE_PATHS = ['/ping', '/ping.json', '/health', '/health.json'].freeze

Sentry.init do |config|
  config.dsn = Settings.sentry.dsn
  config.traces_sample_rate = 1.0
  config.profiles_sample_rate = 1.0

  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.release = ENV.fetch('APPVERSION', 'unknown')

  config.traces_sampler = lambda do |sampling_context|
    transaction_context = sampling_context[:transaction_context]
    transaction_name = transaction_context[:name]

    transaction_name.in?(EXCLUDE_PATHS) ? 0.0 : 0.01
  end

  config.before_send = lambda do |event, hint|
    # NOTE: hint[:exception] would be a String if you use async callback
    if hint[:exception].is_a?(Puma::HttpParserError)
      nil
    else
      event
    end
  end
end
