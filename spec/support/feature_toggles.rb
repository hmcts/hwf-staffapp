module FeatureToggles
  def enable_evidence_check
    before { Settings.evidence_check.enabled = true }
  end

  def disable_evidence_check
    before { Settings.evidence_check.enabled = false }
  end

  def enable_payment
    before { Settings.payment.enabled = true }
  end

  def disable_payment
    before { Settings.payment.enabled = false }
  end
end

RSpec.configure do |config|
  config.extend FeatureToggles, type: :feature
end
