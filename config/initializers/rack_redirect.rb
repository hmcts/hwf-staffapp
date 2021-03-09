# rubocop:disable Style/HashConversion
if Settings.redirection.domains.present?
  setup = Hash[*Settings.redirection.domains.split(':')]

  Rails.application.config.middleware.use Rack::HostRedirect, setup
end
# rubocop:enable Style/HashConversion
