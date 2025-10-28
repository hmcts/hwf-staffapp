require 'rails_helper'

RSpec.describe GuideHelper do

  describe '#how_to_url' do
    it { expect(helper.how_to_url).to include('https://intranet.justice.gov.uk/documents/2017/10/help-with-fees-how-to-guide.pdf') }
  end

  describe '#training_course_url' do
    it { expect(helper.training_course_url).to include('https://mydevelopment.org.uk/course/view.php?id=9824') }
  end

  describe '#key_control_checks_url' do
    it { expect(helper.key_control_checks_url).to include('https://intranet.justice.gov.uk/documents/2017/02/help-with-fees-kccs.docx') }
  end

  describe '#staff_guidance_url' do
    it { expect(helper.staff_guidance_url).to include('https://intranet.justice.gov.uk/documents/2023/12/help-with-fees-policy-guide-for-applications-post-27th-november-23.pdf/') }
  end

  describe '#old_process_application_url' do
    it { expect(helper.old_process_application_url).to include('https://intranet.justice.gov.uk/documents/2021/11/processing-a-help-with-fees-application.docx') }
  end

  describe '#new_process_application_url' do
    it { expect(helper.new_process_application_url).to include('https://intranet.justice.gov.uk/documents/2024/11/process-a-paper-help-with-fees-application.pdf/') }
  end

  describe '#new_online_process_application_url' do
    it { expect(helper.new_online_process_application_url).to include('https://intranet.justice.gov.uk/documents/2024/11/processing-an-online-help-with-fees-application.pdf/') }
  end

  describe '#old_evidence_checks_url' do
    it { expect(helper.old_evidence_checks_url).to include('https://intranet.justice.gov.uk/documents/2020/12/help-with-fees-processing-evidence-job-card.pdf') }
  end

  describe '#new_evidence_checks_url' do
    it { expect(helper.new_evidence_checks_url).to include('https://intranet.justice.gov.uk/documents/2024/11/process-a-help-with-fees-evidence.pdf/') }
  end

  describe '#part_payment_url' do
    it { expect(helper.part_payment_url).to include('https://intranet.justice.gov.uk/documents/2024/11/process-a-help-with-fees-part-payment.pdf/') }
  end

  describe '#fraud_awareness_url' do
    it { expect(helper.fraud_awareness_url).to include('https://intranet.justice.gov.uk/documents/2018/05/help-with-fees-fraud-awareness-pdf.pdf') }
  end

  describe '#rrds_url' do
    it { expect(helper.rrds_url).to include('https://www.gov.uk/government/publications/record-retention-and-disposition-schedules') }
  end

  describe '#datashare_url' do
    it { expect(helper.datashare_url).to include('https://intranet.justice.gov.uk/my-work/help-with-fees/help-with-fees-guidance-documents/') }
  end
end
