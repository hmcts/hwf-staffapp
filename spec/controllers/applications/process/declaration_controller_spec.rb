require 'rails_helper'

RSpec.describe Applications::Process::DeclarationController do
  let(:user)        { create(:user) }
  let(:application) { build_stubbed(:application, office: user.office, detail: detail) }
  let(:detail) { build_stubbed(:detail) }

  let(:application_declaration_form) { instance_double(Forms::Application::Declaration) }

  before do
    sign_in user
    allow(Application).to receive(:find).with(application.id.to_s).and_return(application)
    allow(Forms::Application::Declaration).to receive(:new).with(application.detail).and_return(application_declaration_form)
  end

  describe 'GET #index' do
    before do
      get :index, params: { application_id: application.id }
    end

    context 'when the application does exist' do
      it 'responds with 200' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template('applications/process/declaration/index')
      end

      it 'assigns the correct form' do
        expect(assigns(:form)).to eql(application_declaration_form)
      end
    end
  end

  describe 'POST #create' do
    let(:success) { true }
    let(:app_form) do
      instance_double(ApplicationFormRepository,
                      success?: success,
                      process: application_declaration_form)
    end
    let(:expected_params) { { discretion_applied: 'true' } }
    let(:signed_by) { 'applicant' }

    before do
      allow(ApplicationFormRepository).to receive(:new).with(application, expected_params).and_return app_form
      allow(detail).to receive_messages(update: true, statement_signed_by: signed_by)

      post :create, params: { application_id: application.id, application: expected_params }
    end

    context 'when the ApplicationFormSave is success' do
      let(:detail) { build_stubbed(:complete_detail) }

      context 'signed by applicant' do
        it 'redirects to summary page' do
          expect(response).to redirect_to(application_summary_path(application))
        end
      end

      context 'signed by representative' do
        let(:signed_by) { 'litigation_friend' }
        it 'redirects to representative page' do
          expect(response).to redirect_to(application_representative_path(application))
        end
      end

      context 'signed by is blank' do
        let(:signed_by) { nil }
        it 'redirects to summary page' do
          expect(response).to redirect_to(application_summary_path(application))
        end
      end

    end

    context 'when the form can not be saved' do
      let(:success) { false }

      it 'renders the correct template' do
        expect(response).to render_template('applications/process/declaration/index')
      end

      it 'assigns the correct form' do
        expect(assigns(:form)).to eql(application_declaration_form)
      end
    end
  end
end
