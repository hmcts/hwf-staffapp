module FeatureToggles
  def enable_processed_applications
    before { Settings.processed_applications.enabled = true }
  end

  def disable_processed_applications
    before { Settings.processed_applications.enabled = false }
  end
end

RSpec.configure do |config|
  config.extend FeatureToggles, type: :feature
end
