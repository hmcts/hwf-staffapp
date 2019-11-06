require 'rails_helper'
RSpec.describe Applications::Process::LitigationDetailsController do
  let(:user)          { create :user }
  let(:application) { build_stubbed(:application, office: user.office, detail: detail) }
  let(:detail) { build_stubbed(:detail) }

  let(:litigation_form) { instance_double('Forms::Application::LitigationDetail') }

  before do
    sign_in user
    allow(Application).to receive(:find).with(application.id.to_s).and_return(application)
    allow(Forms::Application::LitigationDetail).to receive(:new).with(application.applicant).and_return(litigation_form)
  end

  describe 'GET #litigation_details' do
    before do
      get :index, params: { application_id: application.id }
    end

    context 'when the application does exist' do
      it 'responds with 200' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template(:index)
      end

      it 'assigns the correct form' do
        expect(assigns(:form)).to eql(litigation_form)
      end
    end
  end

  describe 'PUT #litigation_details' do
    let(:expected_params) { { litigation_friend_details: 'As a friend' } }

    before do
      allow(litigation_form).to receive(:update_attributes).with(expected_params)
      allow(litigation_form).to receive(:save).and_return(form_save)

      post :create, params: { application_id: application.id, application: expected_params }
    end

    context 'when the form can be saved' do
      let(:form_save) { true }

      it 'redirects to application_details' do
        expect(response).to redirect_to(application_details_path(application))
      end
    end

    context 'when the form can not be saved' do
      let(:form_save) { false }

      it 'renders the correct template' do
        expect(response).to render_template(:index)
      end

      it 'assigns the correct form' do
        expect(assigns(:form)).to eql(litigation_form)
      end
    end
  end

  context 'after an application is processed' do
    let!(:application) { create :application, :processed_state, office: user.office }

    describe 'when accessing the litgation details view' do
      before { get :index, params: { application_id: application.id } }

      subject { response }

      it { is_expected.to have_http_status(:redirect) }

      it { is_expected.to redirect_to(processed_application_path(application)) }

      it 'is expected to set the flash message' do
        expect(flash[:alert]).to eql 'This application has been processed. You can’t edit any details.'
      end
    end
  end

end
