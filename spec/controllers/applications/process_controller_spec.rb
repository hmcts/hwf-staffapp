require 'rails_helper'

RSpec.describe Applications::ProcessController, type: :controller do
  include Devise::TestHelpers

  let(:user)          { create :user }
  let(:application) { build_stubbed(:application) }

  let(:personal_information_form) { double }

  before do
    sign_in user
    allow(Application).to receive(:find).with(application.id.to_s).and_return(application)
    allow(Applikation::Forms::PersonalInformation).to receive(:new).with(application.applicant).and_return(personal_information_form)
  end

  describe 'GET #personal_information' do
    before do
      get :personal_information, application_id: application.id
    end

    context 'when the application does exist' do
      it 'responds with 200' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template(:personal_information)
      end

      it 'assigns the correct form' do
        expect(assigns(:form)).to eql(personal_information_form)
      end
    end
  end

  describe 'PUT #personal_information_save' do
    let(:expected_params) { { last_name: 'Name', date_of_birth: '20/01/2980', married: false } }

    before do
      allow(personal_information_form).to receive(:update_attributes).with(expected_params)
      allow(personal_information_form).to receive(:save).and_return(form_save)

      put :personal_information_save, application_id: application.id, personal_information: expected_params
    end

    context 'when the form can be saved' do
      let(:form_save) { true }

      it 'redirects to application_details in the old BuildController' do
        expect(response).to redirect_to(application_build_path(application_id: application.id, id: :application_details))
      end
    end

    context 'when the form can not be saved' do
      let(:form_save) { false }

      it 'renders the correct template' do
        expect(response).to render_template(:personal_information)
      end

      it 'assigns the correct form' do
        expect(assigns(:form)).to eql(personal_information_form)
      end
    end
  end
end
