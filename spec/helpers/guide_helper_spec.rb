require 'rails_helper'

RSpec.describe GuideHelper do

  describe '#how_to_url' do
    it { expect(helper.how_to_url).to include('sourcedoc=%7B5D999F01-6E39-4EB6-8703-E3E4A0262580%7D') }
  end

  describe '#training_course_url' do
    it { expect(helper.training_course_url).to include('sourcedoc=%7BB3128FFC-3EF6-4648-B2BB-8A3D8A29E9BA%7D') }
  end

  describe '#key_control_checks_url' do
    it { expect(helper.key_control_checks_url).to include('sourcedoc=%7BF13EB074-F2F7-4349-BC0A-BA191503BBE9%7D') }
  end

  describe '#staff_guidance_url' do
    it { expect(helper.staff_guidance_url).to include('sourcedoc=%7BDD4BE471-9B43-43D4-9E71-0FB28A9B41EE%7D') }
  end

  describe '#old_process_application_url' do
    it { expect(helper.old_process_application_url).to include('https://intranet.justice.gov.uk/documents/2021/11/processing-a-help-with-fees-application.docx') }
  end

  describe '#new_process_application_url' do
    it { expect(helper.new_process_application_url).to include('sourcedoc=%7BB62AF5DB-DF50-4415-A261-A4598E61B298%7D') }
  end

  describe '#new_online_process_application_url' do
    it { expect(helper.new_online_process_application_url).to include('sourcedoc=%7B1ADE6338-5A41-4D11-8047-ACBB1A070C19%7D') }
  end

  describe '#old_evidence_checks_url' do
    it { expect(helper.old_evidence_checks_url).to include('https://intranet.justice.gov.uk/documents/2020/12/help-with-fees-processing-evidence-job-card.pdf') }
  end

  describe '#new_evidence_checks_url' do
    it { expect(helper.new_evidence_checks_url).to include('sourcedoc=%7B40446293-A8A9-4003-B09E-F228F727A441%7D') }
  end

  describe '#part_payment_url' do
    it { expect(helper.part_payment_url).to include('sourcedoc=%7BA5D5C042-C211-45A6-B1C5-22275AC6E0C5%7D') }
  end

  describe '#fraud_awareness_url' do
    it { expect(helper.fraud_awareness_url).to include('sourcedoc=%7B03E83158-CD55-45F0-9D99-FC7B02BF2343%7D') }
  end

  describe '#rrds_url' do
    it { expect(helper.rrds_url).to include('sourcedoc=%7B34D2BF32-AEB1-41D7-BF74-9C76A6E8042B%7D') }
  end

  describe '#datashare_url' do
    it { expect(helper.datashare_url).to include('sourcedoc=%7BD130FF65-E19C-4A4D-9F02-5E2FF579B229%7D') }
  end

  describe '#faq_url' do
    it { expect(helper.faq_url).to include('HWF%5FFAQ%20%5FOriginal%5FVersion1%2E0%5F28%2E10%2E2025%2Epdf') }
  end
end
