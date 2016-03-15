class HwfReferenceGenerator

  def initialize
    generate_reference
  end

  def attributes
    { reference: @new_reference }
  end

  private

  def generate_reference
    loop do
      @new_reference = "HWF-#{SecureRandom.hex(3).upcase.scan(/.{1,3}/).join('-')}"
      break if OnlineApplication.find_by(reference: @new_reference).nil?
    end
  end
end
