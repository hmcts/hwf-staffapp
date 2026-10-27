module BenefitCheckers
  # The person a DWP match was made for, checked against the citizen record
  # that comes back, so claims are only read for the right person. Only the
  # fields DWP sends are compared; a field it leaves out cannot fail. See CHANGELOG.md
  class MatchedCitizen
    attr_reader :failed_on

    # request: the match request as built; matched: the request DWP answered,
    # a name variant of it; ni_number: the application's, nil when none was given
    def initialize(request, matched, ni_number)
      @date_of_birth = request[:date_of_birth]
      @last_names = [request[:last_name], matched[:last_name]].compact.uniq
      @ni_number = ni_number
    end

    # True when nothing DWP sent disagrees with what we sent; failed_on names the first field that did
    def verify(citizen)
      attributes = citizen.dig('data', 'attributes') || {}
      @checked = []
      @failed_on = first_mismatch(attributes)
      @failed_on.nil?
    end

    # What was compared, our values only. Stored as the verify_citizen request params
    def compared
      { date_of_birth: @date_of_birth, last_names: @last_names, ni_number: @ni_number }.compact
    end

    # checked lists the fields DWP held and we compared, so an empty record reads as "nothing to check"
    def outcome
      { 'verified' => @failed_on.nil?, 'failed_on' => @failed_on&.to_s, 'checked' => @checked.map(&:to_s) }
    end

    private

    def first_mismatch(attributes)
      return :date_of_birth unless date_of_birth_agrees?(attributes.dig('dateOfBirth', 'date'))
      return :last_name unless last_name_held?(attributes)
      return :ni_number unless ni_number_agrees?(attributes['nino'])

      nil
    end

    def date_of_birth_agrees?(held)
      return true if held.blank?

      @checked << :date_of_birth
      held == @date_of_birth
    end

    # DWP may hold a two word surname either way round, or the name as the alternate name
    def last_name_held?(attributes)
      held = [attributes.dig('name', 'lastName'), attributes.dig('alternateName', 'lastName')].compact_blank
      return true if held.empty?

      @checked << :last_name
      held = held.map { |name| normalise(name) }
      @last_names.any? { |name| held.include?(normalise(name)) }
    end

    # Only compared when both DWP and the application have one
    def ni_number_agrees?(held)
      return true if held.blank? || @ni_number.blank?

      @checked << :ni_number
      normalise(held) == normalise(@ni_number)
    end

    def normalise(value)
      value.to_s.delete(' ').downcase
    end
  end
end
