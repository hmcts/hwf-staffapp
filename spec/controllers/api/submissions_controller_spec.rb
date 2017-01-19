require 'rails_helper'

RSpec.describe Api::SubmissionsController, type: :controller do
  let(:auth_token) { 'my-big-secret' }
  let(:submitted) { attributes_for :public_app_submission }

  before do
    allow(Settings.submission).to receive(:token).and_return('my-big-secret')
    controller.request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(auth_token)
    post :create, online_application: submitted
  end

  describe 'POST #create' do
    describe 'when sent the correct authentication header' do
      subject(:returned) { response }

      it { is_expected.to have_http_status(:success) }

      describe 'body' do
        subject(:body) { returned.body }

        it { is_expected.to include 'message' }
        it { is_expected.to include 'result' }
      end

      describe 'when sent invalid data from the public' do
        subject(:result) { JSON.parse(returned.body)['result'] }

        let(:submitted) { attributes_for :public_app_submission, postcode: nil }

        it { is_expected.to be false }
      end

      describe 'when email provided' do
        subject(:addressed_to) { ActionMailer::Base.deliveries.first.to }

        let(:submitted) { attributes_for :public_app_submission, :email_contact }

        it { is_expected.to eq ['foo@bar.com'] }
      end

      describe 'when email provided and refund is true' do
        subject(:addressed_to) { ActionMailer::Base.deliveries.first.subject }

        let(:submitted) { attributes_for :public_app_submission, :email_contact, :refund }

        it { is_expected.to eq I18n.t('email.refund.subject') }
      end

      describe 'when email provided and it is an ET application' do
        subject(:addressed_to) { ActionMailer::Base.deliveries.first.subject }

        let(:submitted) { attributes_for :public_app_submission, :email_contact, :et }

        it { is_expected.to eq I18n.t('email.et.subject') }
      end

      describe 'when email not provided' do
        subject(:action_mailer_count) { ActionMailer::Base.deliveries.count }

        let(:submitted) { attributes_for :public_app_submission }

        it 'does not create an email' do
          expect(action_mailer_count).to eq 0
        end
      end
    end

    describe 'when sent the incorrect authentication header' do
      subject { response }

      let(:auth_token) { 'different-big-secret' }

      it { is_expected.to have_http_status(:unauthorized) }
    end
  end
end
