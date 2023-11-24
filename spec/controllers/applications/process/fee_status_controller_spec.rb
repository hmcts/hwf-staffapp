require 'rails_helper'

RSpec.describe Applications::Process::FeeStatusController do
  # include Rails.application.routes.url_helpers
  let(:user)          { create(:user) }
  let(:application) { build_stubbed(:application, office: user.office, detail: detail) }
  let(:detail) { build_stubbed(:detail) }

  let(:application_fee_status_form) { instance_double(Forms::Application::FeeStatus) }

  before do
    sign_in user
    allow(Application).to receive(:find).with(application.id.to_s).and_return(application)
    allow(Forms::Application::FeeStatus).to receive(:new).with(application.detail).and_return(application_fee_status_form)
  end

  describe 'GET #application_details' do
    before do
      get :index, params: { application_id: application.id }
    end

    context 'when the application does exist' do
      it 'responds with 200' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template('applications/process/fee_status/index')
      end

      it 'assigns the correct form' do
        expect(assigns(:form)).to eql(application_fee_status_form)
      end
    end
  end

  describe 'POST #create' do
    let(:success) { true }
    let(:app_form) do
      instance_double(ApplicationFormRepository,
                      success?: success,
                      process: application_fee_status_form)
    end
    let(:expected_params) { { discretion_applied: 'true' } }

    before do
      allow(ApplicationFormRepository).to receive(:new).with(application, expected_params).and_return app_form
      allow(detail).to receive(:update).and_return(true)

      post :create, params: { application_id: application.id, application: expected_params }
    end

    context 'when the ApplicationFormSave is success' do
      let(:detail) { build_stubbed(:complete_detail) }

      it 'redirects to next page' do
        expect(response).to redirect_to(application_personal_informations_path(application))
      end
    end

    context 'when the form can not be saved' do
      let(:success) { false }

      it 'renders the correct template' do
        expect(response).to render_template('applications/process/fee_status/index')
      end

      it 'assigns the correct form' do
        expect(assigns(:form)).to eql(application_fee_status_form)
      end
    end
  end
end
