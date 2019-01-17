require 'rails_helper'

RSpec.describe GuideHelper do

  describe '#staff_guidance_url' do
    it { expect(helper.staff_guidance_url).to include('https://intranet.justice.gov.uk/documents/2017/10/help-with-fees-policy-guide.pdf') }
  end

  describe '#how_to_url' do
    it { expect(helper.how_to_url).to include('https://intranet.justice.gov.uk/documents/2017/10/help-with-fees-how-to-guide.pdf') }
  end

  describe '#key_control_checks_url' do
    it { expect(helper.key_control_checks_url).to include('https://intranet.justice.gov.uk/documents/2017/10/help-with-fees-key-control-checks.pdf') }
  end

  describe '#fraud_awareness_url' do
    it { expect(helper.fraud_awareness_url).to include('https://intranet.justice.gov.uk/documents/2018/05/help-with-fees-fraud-awareness-pdf.pdf') }
  end
end
