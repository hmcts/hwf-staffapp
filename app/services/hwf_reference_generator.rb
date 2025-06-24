class HwfReferenceGenerator

  def initialize(benefits = 'false')
    @benefits = benefits
  end

  def attributes
    { reference: generate_reference }
  end

  private

  def generate_reference
    begin
      reference = reference_string
    end until prefix_is_unique(reference) && OnlineApplication.find_by(reference: reference).nil?

    reference
  end

  def reference_string
    ref = SecureRandom.alphanumeric(5).upcase.insert(2, '-')
    @benefits == 'true' ? "HWF-Z#{ref}" : "HWF-A#{ref}"
  end

  def prefix_is_unique(reference)
    reference.scan(/(HWF)+/i).one?
  end
end
