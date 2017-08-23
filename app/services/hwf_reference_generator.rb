class HwfReferenceGenerator

  DICTIONARY = [
    '3', '4', '6', '7', '9', 'A', 'C', 'D', 'E', 'F', 'G', 'H', 'J',
    'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'T', 'V', 'W', 'X', 'Y'
  ].freeze

  LENGTH = 6

  def attributes
    { reference: generate_reference }
  end

  private

  def generate_reference
    begin
      reference = reference_string
    end until OnlineApplication.find_by(reference: reference).nil?

    reference
  end

  def reference_string
    "HWF-#{Array.new(LENGTH) { DICTIONARY.sample }.join.scan(/.{1,3}/).join('-')}"
  end
end
