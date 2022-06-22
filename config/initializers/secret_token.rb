class SecretToken
  def self.generate
    Rails.env.production? ? ENV.fetch('SECRET_TOKEN', nil) : ('a' * 30)
  end
end

FrStaffapp::Application.config.secret_key_base = SecretToken.generate
