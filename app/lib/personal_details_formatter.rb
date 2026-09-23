# Normalises identifiers typed by staff before they are validated and stored.
module PersonalDetailsFormatter
  module_function

  # National Insurance and Home Office numbers: no spaces, upper case
  def compact_upcase(value)
    return if value.nil?

    value.delete(' ').upcase
  end

  # UK postcode: runs of spaces become one, upper case, blank becomes nil
  def postcode(value)
    value.to_s.squish.upcase.presence
  end
end
