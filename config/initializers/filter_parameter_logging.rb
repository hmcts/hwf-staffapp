# Be sure to restart your server when you modify this file.

# Configure parameters to be partially matched (e.g. passw matches password) and filtered from the log file.
# Use this to limit dissemination of sensitive information.
# See the ActiveSupport::ParameterFilter documentation for supported notations and behaviors.
Rails.application.config.filter_parameters += [:password, :ni_number, :ho_number, :date_of_birth, :first_name,
  :last_name, :address, :postcode, :email_address, :encrypted_access_token, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn]


