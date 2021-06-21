require 'rails_helper'

RSpec.describe NotifyMailer, type: :mailer do
  let(:application) { build :online_application_with_all_details, :with_reference, date_received: DateTime.parse('1 June 2021') }

  describe '#submission_confirmation' do
    let(:mail) { described_class.submission_confirmation(application) }

    it_behaves_like 'a Notify mail', template_id: ENV['NOTIFY_COMPLETED_TEMPLATE_ID']

    it 'has the right keys' do
      expect(mail.govuk_notify_personalisation).to eq({
                                                        application_reference_code: application.reference,
                                                        enter_details_here: 'Forn name?',
                                                        application_submitted_date: DateTime.parse('1 June 2021'),
                                                        applicant_name: 'Peter Smith'
                                                      })
    end

    it { expect(mail.to).to eq(['peter.smith@example.com']) }
  end

  describe '#submission_confirmation_refund' do
    let(:mail) { described_class.submission_confirmation_refund(application) }

    it_behaves_like 'a Notify mail', template_id: ENV['NOTIFY_COMPLETED_REFUND_TEMPLATE_ID']

    it 'has the right keys' do
      expect(mail.govuk_notify_personalisation).to eq({
                                                        application_reference_code: application.reference,
                                                        application_submitted_date: DateTime.parse('1 June 2021'),
                                                        applicant_name: 'Peter Smith'
                                                      })
    end

    it { expect(mail.to).to eq(['peter.smith@example.com']) }
  end
end
