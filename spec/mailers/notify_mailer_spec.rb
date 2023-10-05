require 'rails_helper'

RSpec.describe NotifyMailer do
  let(:application) { build(:online_application_with_all_details, :with_reference, date_received: DateTime.parse('1 June 2021')) }
  let(:user) { build(:user, name: 'John Jones', invitation_token: '123456abcd', email: 'petr@test.gov.uk') }

  describe '#password_reset' do
    let(:mail) { described_class.password_reset(user, 'http://reset_link') }

    it_behaves_like 'a Notify mail', template_id: ENV.fetch('NOTIFY_PASSWORD_RESET_TEMPLATE_ID', nil)

    it 'has the right values' do
      expect(mail.govuk_notify_personalisation).to eq({
                                                        name: 'John Jones',
                                                        password_link: 'http://reset_link'
                                                      })
    end

  end

  describe '#dwp_is_down_notifier' do
    let(:mail) { described_class.dwp_is_down_notifier }

    it_behaves_like 'a Notify mail', template_id: ENV.fetch('NOTIFY_DWP_DOWN_TEMPLATE_ID', nil)

    it 'has the right values' do
      expect(mail.govuk_notify_personalisation).to eq({
                                                        environment: 'test'
                                                      })
      expect(mail.to).to eq(['dan@test.com', 'petr@test.gov.uk'])
    end

  end

  describe '#user_invite' do
    let(:mail) { described_class.user_invite(user) }

    it_behaves_like 'a Notify mail', template_id: ENV.fetch('NOTIFY_USER_INVOTE_TEMPLATE_ID', nil)

    it 'has the right values' do
      expect(mail.govuk_notify_personalisation).to eq({
                                                        name: 'John Jones',
                                                        invite_url: "http://localhost:3000/users/invitation/accept"
                                                      })
      expect(mail.to).to eq(['petr@test.gov.uk'])
    end
  end

  describe '#submission_confirmation_online' do
    let(:mail) { described_class.submission_confirmation_online(application, 'en') }

    it_behaves_like 'a Notify mail', template_id: ENV.fetch('NOTIFY_COMPLETED_ONLINE_TEMPLATE_ID', nil)

    it 'has the right keys with form_name' do
      application.form_name = ''
      expect(mail.govuk_notify_personalisation).to eq({ application_reference_code: application.reference })
    end

    it 'has the right keys with case number' do
      application.form_name = 'FGDH122'
      expect(mail.govuk_notify_personalisation).to eq({ application_reference_code: application.reference })
    end

    it 'when case and form number is empty' do
      application.form_name = ''
      application.case_number = ''
      expect(mail.govuk_notify_personalisation).to eq({ application_reference_code: application.reference })
    end

    it { expect(mail.to).to eq(['peter.smith@example.com']) }

    context 'welsh' do
      let(:mail) { described_class.submission_confirmation_online(application, 'cy') }
      it_behaves_like 'a Notify mail', template_id: ENV.fetch('NOTIFY_COMPLETED_CY_ONLINE_TEMPLATE_ID', nil)
    end

  end

  describe '#submission_confirmation_refund' do
    let(:mail) { described_class.submission_confirmation_refund(application, 'en') }

    it_behaves_like 'a Notify mail', template_id: ENV.fetch('NOTIFY_COMPLETED_NEW_REFUND_TEMPLATE_ID', nil)

    it 'has the right keys with form_name' do
      application.form_name = ''
      expect(mail.govuk_notify_personalisation).to eq({ application_reference_code: application.reference })
    end

    it 'has the right keys with case number' do
      application.form_name = 'FGDH122'
      expect(mail.govuk_notify_personalisation).to eq({ application_reference_code: application.reference })
    end

    it 'when case and form number is empty' do
      application.form_name = ''
      application.case_number = ''
      expect(mail.govuk_notify_personalisation).to eq({ application_reference_code: application.reference })
    end

    it { expect(mail.to).to eq(['peter.smith@example.com']) }

    context 'welsh' do
      let(:mail) { described_class.submission_confirmation_refund(application, 'cy') }
      it_behaves_like 'a Notify mail', template_id: ENV.fetch('NOTIFY_COMPLETED_CY_NEW_REFUND_TEMPLATE_ID', nil)
    end
  end
end
