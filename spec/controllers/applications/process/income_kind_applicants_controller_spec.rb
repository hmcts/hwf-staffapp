require 'rails_helper'

RSpec.describe Applications::Process::IncomeKindApplicantsController do
  let(:user)          { create(:user) }
  let(:application) { build_stubbed(:application, :applicant_full, office: user.office, married: married) }
  let(:income_kind_form) { instance_double(Forms::Application::IncomeKindApplicant) }
  let(:married) { false }

  before do
    sign_in user
    allow(Application).to receive(:find).with(application.id.to_s).and_return(application)
    allow(Forms::Application::IncomeKindApplicant).to receive(:new).with(application).and_return(income_kind_form)
  end

  describe 'GET #income' do
    let(:application) { build_stubbed(:application, office: user.office, benefits: benefits, married: married) }

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
        expect(assigns(:form)).to eql(income_kind_form)
      end
    end
  end

  describe 'PUT #income_kind_save' do
    let(:expected_params) { { income_kind_applicant: ['test'] } }

    before do
      allow(income_kind_form).to receive(:update).with(expected_params)
      allow(income_kind_form).to receive(:save).and_return(form_save)

      post :create, params: { application_id: application.id, application: expected_params }
    end

    context 'when the form can be saved' do
      let(:form_save) { true }

      it 'redirects to the summary page' do
        expect(response).to redirect_to(application_incomes_path(application))
      end

      context 'married' do
        let(:married) { true }

        it 'redirects to the partner income kind page' do
          expect(response).to redirect_to(application_income_kind_partners_path(application))
        end
      end
    end

    context 'when the form can\'t be saved' do
      let(:form_save) { false }

      it 'renders the correct template' do
        expect(response).to render_template(:index)
      end

      it 'assigns the income form' do
        expect(assigns(:form)).to eql(income_kind_form)
      end
    end
  end

end
