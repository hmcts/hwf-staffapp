class AhoyTrackEventJob < ApplicationJob
  queue_as :default

  def perform(data)
    event_data = data[:event]

    # Extract application_id from properties if present
    application_id = event_data[:properties]&.dig('application_id') ||
                     event_data[:properties]&.dig(:application_id)

    # Only use attributes that Ahoy::Event accepts
    ahoy_event = Ahoy::Event.new(
      name: event_data[:name],
      properties: event_data[:properties],
      time: event_data[:time],
      visit_id: event_data[:visit_id],
      application_id: application_id
    )
    ahoy_event.user = data[:user]

    Rails.logger.info("Ahoy event tracked: #{event_data[:name]} for application #{application_id}")
    ahoy_event.save!
  end
end
