class Ahoy::Store < Ahoy::DatabaseStore
  def track_visit(data)
    # Skip visit tracking - we only care about events
    # No background job needed
  end

  def track_event(data)
    # Track events asynchronously in background job
    AhoyTrackEventJob.perform_later(
      event: data,
      user: user
    )
  end
end

# set to true for JavaScript tracking
Ahoy.api = true

# Disable visit tracking, only track events
# Ahoy.visit_duration = 0
# Ahoy.cookies = false

# set to true for geocoding (and add the geocoder gem to your Gemfile)
# we recommend configuring local geocoding as well
# see https://github.com/ankane/ahoy#geocoding
Ahoy.geocode = false
