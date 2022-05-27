require 'rails_helper'

RSpec.describe NotifyMailer, type: :mailer do
  let(:application) { build :online_application_with_all_details, :with_reference, date_received: DateTime.parse('1 June 2021') }
  let(:user) { build :user, name: 'John Jones' }

  describe '#submission_confirmation' do
    let(:mail) { described_class.password_reset(user, 'http://reset_link') }

    it_behaves_like 'a Notify mail', template_id: ENV['NOTIFY_PASSWORD_RESET_TEMPLATE_ID']

    it 'has the right values' do
      expect(mail.govuk_notify_personalisation).to eq({
                                                        name: 'John Jones',
                                                        password_link: 'http://reset_link'
                                                      })
    end

  end

  describe '#submission_confirmation' do
    let(:mail) { described_class.submission_confirmation(application, 'en') }

    it_behaves_like 'a Notify mail', template_id: ENV['NOTIFY_COMPLETED_TEMPLATE_ID']

    it 'has the right keys with form_name' do
      application.form_name = ''
      expect(mail.govuk_notify_personalisation).to eq({
                                                        application_reference_code: application.reference,
                                                        form_name_case_number: '234567',
                                                        application_submitted_date: Time.zone.today.to_s(:db),
                                                        applicant_name: 'Peter Smith'
                                                      })
    end

    it 'has the right keys with case number' do
      application.form_name = 'FGDH122'
      expect(mail.govuk_notify_personalisation).to eq({
                                                        application_reference_code: application.reference,
                                                        form_name_case_number: 'FGDH122',
                                                        application_submitted_date: Time.zone.today.to_s(:db),
                                                        applicant_name: 'Peter Smith'
                                                      })
    end

    it 'when case and form number is empty' do
      application.form_name = ''
      application.case_number = ''
      expect(mail.govuk_notify_personalisation).to eq({
                                                        application_reference_code: application.reference,
                                                        application_submitted_date: Time.zone.today.to_s(:db),
                                                        applicant_name: 'Peter Smith',
                                                        form_name_case_number: ' '
                                                      })
    end

    it { expect(mail.to).to eq(['peter.smith@example.com']) }

    context 'welsh' do
      let(:mail) { described_class.submission_confirmation(application, 'cy') }
      it_behaves_like 'a Notify mail', template_id: ENV['NOTIFY_COMPLETED_CY_TEMPLATE_ID']
    end

  end

  describe '#submission_confirmation_refund' do
    let(:mail) { described_class.submission_confirmation_refund(application, 'en') }

    it_behaves_like 'a Notify mail', template_id: ENV['NOTIFY_COMPLETED_REFUND_TEMPLATE_ID']

    it 'has the right keys with form_name' do
      application.form_name = ''
      expect(mail.govuk_notify_personalisation).to eq({
                                                        application_reference_code: application.reference,
                                                        form_name_case_number: '234567',
                                                        application_submitted_date: Time.zone.today.to_s(:db),
                                                        applicant_name: 'Peter Smith'
                                                      })
    end

    it 'has the right keys with case number' do
      application.form_name = 'FGDH122'
      expect(mail.govuk_notify_personalisation).to eq({
                                                        application_reference_code: application.reference,
                                                        form_name_case_number: 'FGDH122',
                                                        application_submitted_date: Time.zone.today.to_s(:db),
                                                        applicant_name: 'Peter Smith'
                                                      })
    end

    it 'when case and form number is empty' do
      application.form_name = ''
      application.case_number = ''
      expect(mail.govuk_notify_personalisation).to eq({
                                                        application_reference_code: application.reference,
                                                        application_submitted_date: Time.zone.today.to_s(:db),
                                                        applicant_name: 'Peter Smith',
                                                        form_name_case_number: ' '
                                                      })
    end

    it { expect(mail.to).to eq(['peter.smith@example.com']) }

    context 'welsh' do
      let(:mail) { described_class.submission_confirmation_refund(application, 'cy') }
      it_behaves_like 'a Notify mail', template_id: ENV['NOTIFY_COMPLETED_CY_REFUND_TEMPLATE_ID']
    end
  end
end
