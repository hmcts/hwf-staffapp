require 'rails_helper'

RSpec.describe Applications::Process::PartnerInformationsController do
  let(:user)          { create(:user) }
  let(:application) { build_stubbed(:application, office: user.office, detail: detail) }
  let(:detail) { build_stubbed(:detail) }

  let(:partner_information_form) { instance_double(Forms::Application::Partner) }

  before do
    sign_in user
    allow(Application).to receive(:find).with(application.id.to_s).and_return(application)
    allow(Forms::Application::Partner).to receive(:new).with(application.applicant).and_return(partner_information_form)
  end

  describe 'GET #personal_information' do
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
        expect(assigns(:form)).to eql(partner_information_form)
      end
    end
  end

  describe 'PUT #personal_information_save' do
    let(:expected_params) { { partner_last_name: 'Name', partner_date_of_birth: '20/01/2980' } }
    let(:married) { false }

    before do
      allow(partner_information_form).to receive(:update).with(expected_params)
      allow(partner_information_form).to receive(:save).and_return(form_save)
      allow(application).to receive(:applicant).and_return application.applicant
      allow(application.applicant).to receive(:married?).and_return married

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
        expect(assigns(:form)).to eql(partner_information_form)
      end
    end
  end
end
