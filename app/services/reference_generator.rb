class ReferenceGenerator
  BYTES = 5

  def self.generate
    SecureRandom.hex(BYTES).upcase
  end
end
