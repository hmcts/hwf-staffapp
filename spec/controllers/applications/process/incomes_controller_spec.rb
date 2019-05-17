require 'rails_helper'

RSpec.describe Applications::Process::IncomesController, type: :controller do
  let(:user)          { create :user }
  let(:application) { build_stubbed(:application, office: user.office) }
  let(:income_form) { instance_double('Forms::Application::Income') }
  let(:income_calculation_runner) { instance_double(IncomeCalculationRunner, run: nil) }

  before do
    sign_in user
    allow(Application).to receive(:find).with(application.id.to_s).and_return(application)
    allow(Forms::Application::Income).to receive(:new).with(application).and_return(income_form)
    allow(IncomeCalculationRunner).to receive(:new).with(application).and_return(income_calculation_runner)
  end

  describe 'GET #income' do
    let(:application) { build_stubbed(:application, office: user.office, benefits: benefits) }

    before do
      get :index, params: { application_id: application.id }
    end

    context 'when application is on benefits' do
      let(:benefits) { true }

      it 'redirects to the summary' do
        expect(response).to redirect_to(application_summary_path(application))
      end
    end

    context 'when application is not on benefits' do
      let(:benefits) { false }

      it 'returns 200 response' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template(:index)
      end

      it 'assigns the income form' do
        expect(assigns(:form)).to eql(income_form)
      end
    end
  end

  describe 'PUT #income_save' do
    let(:expected_params) { { 'dependents': 'false' } }

    before do
      allow(income_form).to receive(:update_attributes).with(expected_params)
      allow(income_form).to receive(:save).and_return(form_save)

      post :create, params: { application_id: application.id, application: expected_params }
    end

    context 'when the form can be saved' do
      let(:form_save) { true }

      it 'runs the income calculation on the application' do
        expect(income_calculation_runner).to have_received(:run)
      end

      it 'redirects to the summary page' do
        expect(response).to redirect_to(application_summary_path(application))
      end
    end

    context 'when the form can\'t be saved' do
      let(:form_save) { false }

      it 'renders the correct template' do
        expect(response).to render_template(:index)
      end

      it 'assigns the income form' do
        expect(assigns(:form)).to eql(income_form)
      end
    end
  end

end
