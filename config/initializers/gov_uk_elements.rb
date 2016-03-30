Rails.application.config.tap do |config|
  config.app_title = 'Help with fees'
  config.proposition_title = 'Help with fees'
  config.product_type = 'service'

  # The following values are required by the phase banner
  config.phase = 'beta'
  config.feedback_url = '/feedback'
end
