module BenefitCheckers
  # The ways one person's name is sent to DWP when the request as built finds
  # nobody: words move between first and last name, nothing else changes.
  # At most five requests per person, each labelled with how it differs
  # from the request as built. See CHANGELOG.md
  class NameVariants
    Variant = Struct.new(:label, :request)

    def self.for(request)
      new(request).all
    end

    def initialize(request)
      @request = request
      @first = request[:first_name].to_s.split
      @last = request[:last_name].to_s.split
    end

    def all
      [Variant.new('as sent', @request)] + middle_name_variants + last_name_variants
    end

    private

    # "Anna Maria" "JONES" -> "Anna" "JONES", then "Anna" "Maria JONES"
    def middle_name_variants
      return [] unless @first.size > 1

      [
        Variant.new('middle name dropped', @request.merge(first_name: @first.first)),
        Variant.new('middle name joined to last name',
                    @request.merge(first_name: @first.first, last_name: (@first.drop(1) + @last).join(' ')))
      ]
    end

    # "Anna" "VAN JONES" -> "Anna" "JONES", then "Anna VAN" "JONES"
    def last_name_variants
      return [] unless @last.size > 1

      [
        Variant.new('leading part of last name dropped', @request.merge(last_name: @last.last)),
        Variant.new('leading part of last name joined to first name',
                    @request.merge(first_name: (@first + @last[0...-1]).join(' '), last_name: @last.last))
      ]
    end
  end
end
