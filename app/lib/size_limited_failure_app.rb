# Devise stores the URL an unauthenticated user attempted (including its query
# string) in the session so it can redirect back there after sign in. The
# session lives in a 4KB cookie, so an oversized URL raises
# ActionDispatch::Cookies::CookieOverflow before the login page even renders.
# Skip storing anything oversized - those users land on the homepage instead.
class SizeLimitedFailureApp < Devise::FailureApp
  MAX_STORED_LOCATION_BYTES = 2048

  private

  def store_location!
    return if attempted_path.to_s.bytesize > MAX_STORED_LOCATION_BYTES
    super
  end
end
