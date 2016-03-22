require 'rails_helper'

RSpec.describe Api::SubmissionsController, type: :controller do
  let(:auth_token) { 'my-big-secret' }
  let(:submitted) { attributes_for :public_app_submission }

  before(:each) do
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
        let(:submitted) { attributes_for :public_app_submission, postcode: nil }
        subject(:result) { JSON.parse(returned.body)['result'] }

        it { is_expected.to eql false }
      end
    end

    describe 'when sent the incorrect authentication header' do
      let(:auth_token) { 'different-big-secret' }

      subject { response }

      it { is_expected.to have_http_status(:unauthorized) }
    end
  end
end
