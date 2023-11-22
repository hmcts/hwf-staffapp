require 'rails_helper'

RSpec.describe GuideHelper do

  describe '#old_staff_guidance_url' do
    it { expect(helper.old_staff_guidance_url).to include('https://intranet.justice.gov.uk/documents/2017/10/help-with-fees-policy-guide.pdf') }
  end

  describe '#new_staff_guidance_url' do
    it { expect(helper.new_staff_guidance_url).to include('https://intranet.justice.gov.uk/documents/2017/10/help-with-fees-policy-guide.pdf') }
  end

  describe '#training_course_url' do
    it { expect(helper.training_course_url).to include('https://mydevelopment.org.uk/course/view.php?id=9824') }
  end

  describe '#how_to_url' do
    it { expect(helper.how_to_url).to include('https://intranet.justice.gov.uk/documents/2017/10/help-with-fees-how-to-guide.pdf') }
  end

  describe '#key_control_checks_url' do
    it { expect(helper.key_control_checks_url).to include('https://intranet.justice.gov.uk/documents/2017/02/help-with-fees-kccs.docx') }
  end

  describe '#fraud_awareness_url' do
    it { expect(helper.fraud_awareness_url).to include('https://intranet.justice.gov.uk/documents/2018/05/help-with-fees-fraud-awareness-pdf.pdf') }
  end

  describe '#old_job_cards_url' do
    it { expect(helper.old_job_cards_url).to include('https://intranet.justice.gov.uk/about-hmcts/my-work/help-with-fees/job-cards/') }
  end

  describe '#new_job_cards_url' do
    it { expect(helper.new_job_cards_url).to include('https://intranet.justice.gov.uk/about-hmcts/my-work/help-with-fees/job-cards/') }
  end

  describe '#rrds_url' do
    it { expect(helper.rrds_url).to include('https://www.gov.uk/government/publications/record-retention-and-disposition-schedules') }
  end

end
