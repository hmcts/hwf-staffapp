# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:password, :ni_number, :ho_number, :date_of_birth, :first_name,
                                               :last_name, :address, :postcode, :email_address]
