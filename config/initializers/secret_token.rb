class SecretToken
  def self.generate
    Rails.env.production? ? ENV['SECRET_TOKEN'] : ('a' * 30)
  end
end

FrStaffapp::Application.config.secret_key_base = SecretToken.generate
