# Be sure to restart your server when you modify this file.

# Sessions are stored server-side in Redis rather than in the cookie. The cookie
# only carries the signed session id, so the session can hold more than the
# browser's 4KB cookie limit and never raises ActionDispatch::Cookies::CookieOverflow.
#
# This uses Rails' own cache-backed session store with a dedicated Redis cache
# (rather than a third-party session gem), so it does not touch the app's global
# Rails.cache. If Redis is unreachable the error_handler reports to Sentry and
# the request degrades to no session rather than raising.
#
# expire_after is a rolling inactivity window, NOT a hard cap from login: every
# request that touches the session rewrites the Redis key with a fresh TTL and
# re-sends the cookie with a new expiry (rack-session always re-sets the cookie
# when :expires is present). Active users are therefore never logged out; the
# session only expires after a full hour without any request.
#
# Keep in sync with Devise's config.timeout_in (config/initializers/devise.rb),
# which is refreshed on the same requests - so the Redis key is reclaimed on
# the same schedule the user is timed out for inactivity.
session_cache = ActiveSupport::Cache::RedisCacheStore.new(
  url: Settings.redis_url,
  namespace: 'session',
  error_handler: lambda { |method:, returning:, exception:|
    Sentry.capture_exception(exception, extra: { method: method, returning: returning })
  }
)

Rails.application.config.session_store :cache_store,
                                       cache: session_cache,
                                       key: '_fr-staffapp_session',
                                       expire_after: 1.hour
