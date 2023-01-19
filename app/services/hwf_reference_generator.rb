class HwfReferenceGenerator
  class HwfReferenceDuplicationWarning < StandardError; end

  LENGTH = 6

  def initialize(benefits: false)
    check_uniqueness_count

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
    @benefits ? "HWF-Z#{ref}" : "HWF-A#{ref}"
  end

  def prefix_is_unique(reference)
    reference.scan(/(HWF)+/i).count == 1
  end

  def check_uniqueness_count
    raise HwfReferenceDuplicationWarning if OnlineApplication.where('reference like ?', 'HWF-Z%').count > 1679616
    raise HwfReferenceDuplicationWarning if OnlineApplication.where('reference like ?', 'HWF-A%').count > 1679616
  end
end
