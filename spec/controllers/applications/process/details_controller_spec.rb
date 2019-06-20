require 'rails_helper'

RSpec.describe Applications::Process::DetailsController, type: :controller do
  include Rails.application.routes.url_helpers
  let(:user)          { create :user }
  let(:application) { build_stubbed(:application, office: user.office, detail: detail) }
  let(:detail) { build_stubbed(:detail) }

  let(:application_details_form) { instance_double('Forms::Application::Detail') }

  before do
    sign_in user
    allow(Application).to receive(:find).with(application.id.to_s).and_return(application)
    allow(Forms::Application::Detail).to receive(:new).with(application.detail).and_return(application_details_form)
  end

  describe 'GET #application_details' do
    before do
      get :index, application_id: application.id
    end

    context 'when the application does exist' do
      it 'responds with 200' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template('applications/process/details/index')
      end

      it 'assigns the correct form' do
        expect(assigns(:form)).to eql(application_details_form)
      end

      it 'assigns user\'s jurisdictions' do
        expect(assigns(:jurisdictions)).to eq(user.office.jurisdictions)
      end
    end
  end

  describe 'POST #create' do
    let(:success) { true }
    let(:app_form) do
      instance_double('ApplicationFormRepository',
        success?: success,
        process: application_details_form)
    end
    let(:expected_params) { { discretion_applied: 'true' } }

    before do
      allow(ApplicationFormRepository).to receive(:new).with(application, expected_params).and_return app_form
      allow(detail).to receive(:update).and_return(true)

      post :create, application_id: application.id, application: expected_params
    end

    context 'when the ApplicationFormSave is success' do
      let(:detail) { build_stubbed(:complete_detail) }

      it 'redirects to next page' do
        expect(response).to redirect_to(application_savings_investments_path(application))
      end
    end

    context 'when the form can not be saved' do
      let(:success) { false }

      it 'renders the correct template' do
        expect(response).to render_template('applications/process/details/index')
      end

      it 'assigns the correct form' do
        expect(assigns(:form)).to eql(application_details_form)
      end

      it 'assigns user\'s jurisdictions' do
        expect(assigns(:jurisdictions)).to eq(user.office.jurisdictions)
      end
    end
  end

  context 'fee approval' do
    let(:form) { double }

    before do
      allow(Forms::FeeApproval).to receive(:new).with(application.detail).and_return(form)
    end

    describe 'GET #approve' do
      before do
        get :approve, application_id: application.id
      end

      it 'renders the :approve template' do
        expect(response).to render_template(:approve)
      end

      it 'assigns the form' do
        expect(assigns(:form)).to eql(form)
      end

      it 'assigns the application' do
        expect(assigns(:application)).to eql(application)
      end
    end

    describe 'PUT #approve_save' do
      let(:params) { { fee_manager_firstname: 'Jane', fee_manager_lastname: 'Doe' } }

      before do
        allow(form).to receive(:update_attributes).with(params)
        allow(form).to receive(:save).and_return(form_save)

        put :approve_save, application_id: application.id, application: params
      end

      context 'when the form can be saved' do
        let(:form_save) { true }

        it 'redirects to the savings and investments page' do
          expect(response).to redirect_to(application_savings_investments_path(application))
        end
      end

      context 'when the form can not be saved' do
        let(:form_save) { false }

        it 'renders the edit template' do
          expect(response).to render_template(:approve)
        end
      end
    end
  end
end
