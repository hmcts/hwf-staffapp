class HwfReferenceGenerator

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
    "HWF-#{SecureRandom.hex(3).upcase.scan(/.{1,3}/).join('-')}"
  end
end
