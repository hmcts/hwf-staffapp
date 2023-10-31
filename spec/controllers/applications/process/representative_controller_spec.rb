require 'rails_helper'

RSpec.describe Applications::Process::RepresentativeController do
  let(:user)          { create(:user) }
  let(:application) { build_stubbed(:application, office: user.office, representative: representative) }
  let(:representative) { build_stubbed(:representative) }

  let(:application_representative_form) { instance_double(Forms::Application::Representative) }

  before do
    sign_in user
    allow(Application).to receive(:find).with(application.id.to_s).and_return(application)
    allow(Forms::Application::Representative).to receive(:new).with(application.representative).and_return(application_representative_form)
    allow(Representative).to receive(:find_or_initialize_by).with(application: application)
  end

  describe 'GET #representative' do
    before do
      get :index, params: { application_id: application.id }
    end

    context 'when the representative does exist' do
      it 'responds with 200' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template('applications/process/representative/index')
      end

      it 'assigns the correct form' do
        expect(assigns(:form)).to eql(application_representative_form)
      end

      it 'assigns representative' do
        expect(Representative).to have_received(:find_or_initialize_by).with(application: application)
      end
    end
  end

  describe 'POST #create' do
    let(:success) { true }
    let(:application_representative_form) {
      instance_double(Forms::Application::Representative, save: success)
    }
    let(:expected_params) { { discretion_applied: 'true', first_name: 'a', last_name: 'b', organisation: 'c' } }

    before do
      allow(Forms::Application::Representative).to receive(:new).with(representative).and_return(application_representative_form)
      allow(application_representative_form).to receive(:update).and_return(true)

      post :create, params: { application_id: application.id, application: expected_params }
    end

    context 'when the Form save is success' do
      let(:representative) { build_stubbed(:representative) }

      it 'redirects to next page' do
        expect(response).to redirect_to(application_summary_path(application))
      end
    end

    context 'when the form can not be saved' do
      let(:success) { false }

      it 'renders the correct template' do
        expect(response).to render_template('applications/process/representative/index')
      end

      it 'assigns the correct form' do
        expect(assigns(:form)).to eql(application_representative_form)
      end
    end
  end
end
