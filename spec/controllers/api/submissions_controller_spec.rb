require 'rails_helper'

RSpec.describe Api::SubmissionsController, type: :controller do
  let(:auth_token) { 'my-big-secret' }
  let(:submitted) { attributes_for :public_app_submission }

  describe 'POST #create' do
    before do
      allow(Settings.submission).to receive(:token).and_return('my-big-secret')
      controller.request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(auth_token)
      post :create, params: { online_application: submitted }
    end

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
    end

    describe 'when sent the incorrect authentication header' do
      subject { response }

      let(:auth_token) { 'different-big-secret' }

      it { is_expected.to have_http_status(:unauthorized) }
    end
  end

  describe 'POST create' do
    before do
      allow(Settings.submission).to receive(:token).and_return('my-big-secret')
      controller.request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(auth_token)
    end

    let(:online_application_builder) { instance_double(OnlineApplicationBuilder, build: online_application) }
    let(:online_application) { instance_double(OnlineApplication, save: false) }
    let(:approved_params) do
      { "married" => "true",
        "min_threshold_exceeded" => "true",
        "max_threshold_exceeded" => "false",
        "over_61" => "false",
        "amount" => "3500",
        "benefits" => "true",
        "children" => "0",
        "income" => "100",
        "refund" => "false",
        "probate" => "false",
        "case_number" => submitted[:case_number],
        "form_name" => submitted[:form_name],
        "ni_number" => submitted[:ni_number],
        "date_of_birth" => "1990-01-01",
        "title" => "Mr",
        "first_name" => "Foo",
        "last_name" => "Bar",
        "address" => "1 The Street",
        "postcode" => submitted[:postcode],
        "email_contact" => "false",
        "phone_contact" => "true",
        "phone" => "000 000 0000",
        "post_contact" => "true",
        "feedback_opt_in" => "true",
        "income_kind" => { "applicant" => ["Wages"], "partner" => ["Child Benefit"] } }
    end

    it 'passing allowed params' do
      allow(OnlineApplicationBuilder).to receive(:new).and_return online_application_builder
      post :create, params: { online_application: submitted }
      expect(OnlineApplicationBuilder).to have_received(:new).with(approved_params)
    end
  end
end
