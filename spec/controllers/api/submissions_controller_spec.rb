require 'rails_helper'

RSpec.describe Api::SubmissionsController, type: :controller do
  let(:auth_token) { 'my-big-secret' }
  let(:submitted) { attributes_for :public_app_submission }
  let(:locale) { 'en' }

  describe 'POST #create' do
    before do
      allow(Settings.submission).to receive(:token).and_return('my-big-secret')
      controller.request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(auth_token)
      post :create, params: { online_application: submitted, locale: locale }
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

    context 'mailer' do
      let(:online_application) { instance_double(OnlineApplication, save: true, reference: 'ref124') }
      let(:mailer_service) { instance_double(MailService, send_public_confirmation: true) }
      before do
        allow(OnlineApplicationBuilder).to receive(:new).and_return online_application_builder
        allow(MailService).to receive(:new).and_return mailer_service
        allow(mailer_service).to receive(:send_public_confirmation)
      end

      it 'en local' do
        post :create, params: { online_application: submitted, locale: 'en' }
        expect(MailService).to have_received(:new).with(online_application, 'en')
      end

      it 'cy local' do
        post :create, params: { online_application: submitted, locale: 'cy' }
        expect(MailService).to have_received(:new).with(online_application, 'cy')
      end
    end

  end

end
