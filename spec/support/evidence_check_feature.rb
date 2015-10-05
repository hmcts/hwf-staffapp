module EvidenceCheckFeature
  def enable_evidence_check
    before { Settings.evidence_check.enabled = true }
  end

  def disable_evidence_check
    before { Settings.evidence_check.enabled = false }
  end
end

RSpec.configure do |config|
  config.before(type: :feature) do
    @evidence_check_enabled = Settings.evidence_check.enabled
  end

  config.after(type: :feature) do
    Settings.evidence_check.enabled = @evidence_check_enabled
  end

  config.extend EvidenceCheckFeature, type: :feature
end
