module SpotcheckFeature
  def enable_spotcheck
    before { Settings.spotcheck.enabled = true }
  end

  def disable_spotcheck
    before { Settings.spotcheck.enabled = false }
  end
end

RSpec.configure do |config|
  config.before(type: :feature) do
    @spotcheck_enabled = Settings.spotcheck.enabled
  end

  config.after(type: :feature) do
    Settings.spotcheck.enabled = @spotcheck_enabled
  end

  config.extend SpotcheckFeature, type: :feature
end
