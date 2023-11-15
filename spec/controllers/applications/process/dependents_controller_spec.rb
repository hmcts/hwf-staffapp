require 'rails_helper'

RSpec.describe Applications::Process::DependentsController do
  let(:user)          { create(:user) }
  let(:application) { build_stubbed(:application, office: user.office, detail: detail) }
  let(:detail) { build_stubbed(:detail, calculation_scheme: scheme) }
  let(:income_form) { instance_double(Forms::Application::Dependent) }
  let(:income_calculation_runner) { instance_double(IncomeCalculationRunner, run: nil) }
  let(:scheme) { FeatureSwitching::CALCULATION_SCHEMAS[0] }

  before do
    sign_in user
    allow(Application).to receive(:find).with(application.id.to_s).and_return(application)
    allow(Forms::Application::Dependent).to receive(:new).with(application).and_return(income_form)
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
    let(:expected_params) { { dependents: 'false' } }
    let(:scheme) { FeatureSwitching::CALCULATION_SCHEMAS[0] }

    before do
      allow(income_form).to receive(:update).with(expected_params)
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

    context 'form is saved and UCD applies' do
      let(:form_save) { true }
      let(:scheme) { FeatureSwitching::CALCULATION_SCHEMAS[1] }

      it 'runs the income calculation on the application' do
        expect(income_calculation_runner).to have_received(:run)
      end

      it 'redirects to the income type page' do
        expect(response).to redirect_to(application_income_kind_applicants_path(application))
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
