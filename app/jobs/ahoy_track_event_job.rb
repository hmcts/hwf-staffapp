class AhoyTrackEventJob < ApplicationJob
  queue_as :default

  def perform(data)
    event_data = data[:event]

    # Only use attributes that Ahoy::Event accepts
    ahoy_event = Ahoy::Event.new(
      name: event_data[:name],
      properties: event_data[:properties],
      time: event_data[:time],
      visit_id: event_data[:visit_id]
    )
    ahoy_event.user = data[:user]

    Rails.logger.info("Ahoy event: #{event_data}")
    ahoy_event.save!
  end
end
