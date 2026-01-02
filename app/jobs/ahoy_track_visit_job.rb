class AhoyTrackVisitJob < ApplicationJob
  queue_as :default

  def perform(data)
    visit_data = data[:visit]

    # Create visit with the data Ahoy provides
    # Filter out any attributes that don't belong to the model
    visit = Ahoy::Visit.new(visit_data.slice(
                              :visit_token, :visitor_token, :ip, :user_agent, :referrer,
                              :referring_domain, :landing_page, :browser, :os, :device_type,
                              :country, :region, :city, :latitude, :longitude, :utm_source,
                              :utm_medium, :utm_term, :utm_content, :utm_campaign, :app_version,
                              :os_version, :platform, :started_at
                            ))
    visit.user = data[:user]
    visit.save!
  end
end
