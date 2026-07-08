# Be sure to restart your server when you modify this file.

# Sessions are stored server-side in Redis rather than in the cookie. The cookie
# only carries the signed session id, so the session can hold more than the
# browser's 4KB cookie limit and never raises ActionDispatch::Cookies::CookieOverflow.
#
# This uses Rails' own cache-backed session store with a dedicated Redis cache
# (rather than a third-party session gem), so it does not touch the app's global
# Rails.cache. expire_after matches Devise's config.timeout_in so the Redis key is
# reclaimed on the same schedule the user is timed out. If Redis is unreachable
# the error_handler reports to Sentry and the request degrades to no session
# rather than raising.
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
