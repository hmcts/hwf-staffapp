FrStaffapp::Application.config.secret_key_base =
  if Rails.env.production?
    ENV['SECRET_TOKEN']
  else
    ('a' * 30)
  end
