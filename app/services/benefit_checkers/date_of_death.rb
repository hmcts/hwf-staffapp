module BenefitCheckers
  # A date of death on the citizen record is flagged when it is on or before
  # the application date; a flagged check is No whatever the claims say. See CHANGELOG.md
  module DateOfDeath
    FLAGGED = 'date_of_death_flagged'.freeze
    FORMAT = /\A\d{4}-\d{2}-\d{2}\z/

    module_function

    # citizen_record: the parsed get_citizen body, or nil when there was none
    # application_date: submitted, received or fee paid, the date the effective window ends on
    # Returns the date of death when it is flagged, otherwise nil
    def flagged(citizen_record, application_date)
      date = parse(citizen_record&.dig('data', 'attributes', 'dateOfDeath', 'date'))
      return if date.nil? || application_date.nil?

      date if date <= application_date
    end

    # DWP sends yyyy-mm-dd; anything else is not a date of death
    def parse(value)
      return unless value.to_s.match?(FORMAT)

      Date.iso8601(value)
    rescue Date::Error
      nil
    end
  end
end
