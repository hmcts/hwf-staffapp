class Reference < ActiveRecord::Base
  belongs_to :application

  attr_accessor :entity_code

  after_initialize :check_for_entity_code
  after_initialize :populate_secure_random
  after_initialize :populate_reference_hash

  validates :secure_random, presence: true
  validates :reference_hash, presence: true

  private

  def check_for_entity_code
    if entity_code.blank?
      raise NoMethodError, 'Please provide entity_code when initalising'
    end
  end

  def populate_secure_random
    self.secure_random = SecureRandom.random_bytes(5)
  end

  def populate_reference_hash
    suffix = encoded_secure_random
    self.reference_hash = [@entity_code.upcase, suffix].join('-')
  end

  def encoded_secure_random
    Base32::Crockford.encode(secure_random).scan(/.{1,4}/).join('-')
  end
end
