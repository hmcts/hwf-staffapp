require 'rails_helper'

RSpec.describe Applications::ProcessController, type: :controller do
  let(:user)          { create :user }
  let(:application) { build_stubbed(:application, office: user.office) }

  let(:personal_information_form) { double }
  let(:application_details_form) { double }
  let(:savings_investments_form) { double }
  let(:benefit_form) { double }
  let(:income_form) { double }
  let(:income_calculation_runner) { double(run: nil) }
  let(:savings_pass_fail_service) { double }
  let(:dwp_monitor) { double }
  let(:dwp_state) { 'online' }

  before do
    sign_in user
    allow(Application).to receive(:find).with(application.id.to_s).and_return(application)
    allow(Forms::Application::Applicant).to receive(:new).with(application.applicant).and_return(personal_information_form)
    allow(Forms::Application::Detail).to receive(:new).with(application.detail).and_return(application_details_form)
    allow(Forms::Application::SavingsInvestment).to receive(:new).with(application.saving).and_return(savings_investments_form)
    allow(Forms::Application::Benefit).to receive(:new).with(application).and_return(benefit_form)
    allow(Forms::Application::Income).to receive(:new).with(application).and_return(income_form)
    allow(IncomeCalculationRunner).to receive(:new).with(application).and_return(income_calculation_runner)
    allow(SavingsPassFailService).to receive(:new).with(application.saving).and_return(savings_pass_fail_service)
    allow(dwp_monitor).to receive(:state).and_return(dwp_state)
    allow(DwpMonitor).to receive(:new).and_return(dwp_monitor)
  end

  describe 'POST create' do
    let(:builder) { double(build: application) }

    before do
      allow(ApplicationBuilder).to receive(:new).with(user).and_return(builder)
      allow(application).to receive(:save)

      post :create
    end

    it 'creates a new application' do
      expect(application).to have_received(:save)
    end

    it 'redirects to the personal information page for that application' do
      expect(response).to redirect_to(application_personal_information_path(application))
    end
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

      put :personal_information_save, application_id: application.id, application: expected_params
    end

    context 'when the form can be saved' do
      let(:form_save) { true }

      it 'redirects to application_details' do
        expect(response).to redirect_to(application_application_details_path(application))
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

  describe 'GET #application_details' do
    before do
      get :application_details, application_id: application.id
    end

    context 'when the application does exist' do
      it 'responds with 200' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template(:application_details)
      end

      it 'assigns the correct form' do
        expect(assigns(:form)).to eql(application_details_form)
      end

      it 'assigns user\'s jurisdictions' do
        expect(assigns(:jurisdictions)).to eq(user.office.jurisdictions)
      end
    end
  end

  describe 'PUT #application_details_save' do
    let(:expected_params) { { fee: '300' } }

    before do
      allow(application_details_form).to receive(:update_attributes).with(expected_params)
      allow(application_details_form).to receive(:save).and_return(form_save)

      put :application_details_save, application_id: application.id, application: expected_params
    end

    context 'when the form can be saved' do
      let(:form_save) { true }

      it 'redirects to savings_investments' do
        expect(response).to redirect_to(application_savings_investments_path(application))
      end
    end

    context 'when the form can not be saved' do
      let(:form_save) { false }

      it 'renders the correct template' do
        expect(response).to render_template(:application_details)
      end

      it 'assigns the correct form' do
        expect(assigns(:form)).to eql(application_details_form)
      end

      it 'assigns user\'s jurisdictions' do
        expect(assigns(:jurisdictions)).to eq(user.office.jurisdictions)
      end
    end
  end

  describe 'GET #savings_investments' do
    before do
      get :savings_investments, application_id: application.id
    end

    context 'when the application does exist' do
      it 'responds with 200' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template(:savings_investments)
      end

      it 'assigns the correct form' do
        expect(assigns(:form)).to eql(savings_investments_form)
      end

      it 'assigns the application' do
        expect(assigns(:application)).to eql(application)
      end
    end
  end

  describe 'PUT #savings_investments_save' do
    let(:expected_params) { { min_threshold_exceeded: false } }

    before do
      allow(savings_investments_form).to receive(:update_attributes).with(expected_params)
      allow(savings_investments_form).to receive(:save).and_return(form_save)
      allow(savings_pass_fail_service).to receive(:calculate!).and_return(form_save)
      put :savings_investments_save, application_id: application.id, application: expected_params
    end

    context 'when the form can be saved' do
      let(:form_save) { true }

      it 'redirects to benefits' do
        expect(response).to redirect_to(application_benefits_path(application))
      end
    end

    context 'when the form can not be saved' do
      let(:form_save) { false }

      it 'renders the correct template' do
        expect(response).to render_template(:savings_investments)
      end

      it 'assigns the correct form' do
        expect(assigns(:form)).to eql(savings_investments_form)
      end

      it 'assigns the application' do
        expect(assigns(:application)).to eql(application)
      end
    end
  end

  describe 'GET #benefits' do
    let(:saving) { double }

    before do
      allow(application).to receive(:saving).and_return(saving)
      allow(saving).to receive(:passed?).and_return(savings_valid)

      get :benefits, application_id: application.id
    end

    context 'when application failed savings and investments' do
      let(:savings_valid) { false }

      it 'redirects to the summary' do
        expect(response).to redirect_to(application_summary_path(application))
      end
    end

    context 'when savings and investments passed' do
      let(:savings_valid) { true }

      it 'returns 200 response' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template(:benefits)
      end

      it 'assigns the benefits form' do
        expect(assigns(:form)).to eql(benefit_form)
      end

      describe '@status' do
        subject { assigns(:state) }

        context 'when the dwp is up' do
          it { is_expected.to eql(dwp_state) }
        end

        context 'when the dwp is down' do
          let(:dwp_state) { 'offline' }

          it { is_expected.to eql(dwp_state) }
        end
      end
    end
  end

  describe 'PUT #benefits_save' do
    let(:expected_params) { { benefits: false } }
    let(:benefit_form) { double(benefits: user_says_on_benefits) }
    let(:user_says_on_benefits) { false }
    let(:can_override) { false }
    let(:benefit_check_runner) { double(run: nil, can_override?: can_override) }

    before do
      expect(benefit_form).to receive(:update_attributes).with(expected_params)
      expect(benefit_form).to receive(:save).and_return(form_save)
      allow(BenefitCheckRunner).to receive(:new).with(application).and_return(benefit_check_runner)

      put :benefits_save, application_id: application.id, application: expected_params
    end

    context 'when the form can be saved' do
      let(:form_save) { true }

      context 'when the applicant says they are on benefits' do
        let(:user_says_on_benefits) { true }

        it 'runs the benefit check on the application' do
          expect(benefit_check_runner).to have_received(:run)
        end

        context 'when the result can be overridden' do
          let(:can_override) { true }

          it 'redirects to the benefits override page' do
            expect(response).to redirect_to(application_benefit_override_paper_evidence_path(application))
          end
        end

        context 'when the result can not be overridden' do
          it 'redirects to the summary override page' do
            expect(response).to redirect_to(application_summary_path(application))
          end
        end
      end

      context 'when the applicant says they are not on benefits' do
        let(:user_says_on_benefits) { false }

        it 'does not run benefit check on the application' do
          expect(benefit_check_runner).not_to have_received(:run)
        end

        it 'redirects to the income page' do
          expect(response).to redirect_to(application_income_path(application))
        end
      end
    end

    context 'when the form can\'t be saved' do
      let(:form_save) { false }

      it 'renders the correct template' do
        expect(response).to render_template(:benefits)
      end

      it 'assigns the benefits form' do
        expect(assigns(:form)).to eql(benefit_form)
      end
    end
  end

  describe 'GET #income' do
    let(:application) { build_stubbed(:application, office: user.office, benefits: benefits) }

    before do
      get :income, application_id: application.id
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
        expect(response).to render_template(:income)
      end

      it 'assigns the income form' do
        expect(assigns(:form)).to eql(income_form)
      end
    end
  end

  describe 'PUT #income_save' do
    let(:expected_params) { { dependents: false } }

    before do
      expect(income_form).to receive(:update_attributes).with(expected_params)
      expect(income_form).to receive(:save).and_return(form_save)

      put :income_save, application_id: application.id, application: expected_params
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
        expect(response).to render_template(:income)
      end

      it 'assigns the income form' do
        expect(assigns(:form)).to eql(income_form)
      end
    end
  end

  describe 'GET #summary' do
    before do
      get :summary, application_id: application.id
    end

    context 'when the application does exist' do
      it 'responds with 200' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template(:summary)
      end

      it 'assigns application' do
        expect(assigns(:application)).to eql(application)
      end

      it 'assigns result' do
        expect(assigns(:result)).to be_a_kind_of(Views::ProcessedApplicationResult)
      end

      it 'assigns overview' do
        expect(assigns(:overview)).to be_a_kind_of(Views::ApplicationOverview)
      end

      it 'assigns savings' do
        expect(assigns(:savings)).to be_a_kind_of(Views::Overview::SavingsAndInvestments)
      end

      it 'assigns benefits' do
        expect(assigns(:benefits)).to be_a_kind_of(Views::Overview::Benefits)
      end

      it 'assigns income' do
        expect(assigns(:income)).to be_a_kind_of(Views::Overview::Income)
      end
    end
  end

  describe 'POST #summary_save' do
    let(:current_time) { Time.zone.now }
    let(:user) { create :user }
    let(:application) { create :application_full_remission, office: user.office }
    let(:resolver) { double(complete: nil) }

    before do
      expect(ResolverService).to receive(:new).with(application, user).and_return(resolver)

      Timecop.freeze(current_time) do
        sign_in user
        post :summary_save, application_id: application.id
      end
    end

    it 'returns the correct status code' do
      expect(response).to have_http_status(302)
    end

    it 'redirects to the confirmation page' do
      expect(response).to redirect_to(application_confirmation_path(application.id))
    end

    it 'completes the application using the ResolverService' do
      expect(resolver).to have_received(:complete)
    end
  end

  describe 'PUT #override' do
    let!(:application) { create(:application, office: user.office) }
    let(:override_reason) { nil }
    let(:params) { { value: override_value, reason: override_reason, created_by_id: user.id } }

    before { put :override, application_id: application.id, application: params }

    context 'when the parameters are valid' do
      context 'by selecting a radio button' do
        let(:override_value) { 1 }

        it 'redirects to the confirmation page' do
          expect(response).to redirect_to(application_confirmation_path(application))
        end
      end

      context 'by selecting `other` and providing a reason' do
        let(:override_value) { 'other' }
        let(:override_reason) { 'foo bar' }

        it 'redirects to the confirmation page' do
          expect(response).to redirect_to(application_confirmation_path(application))
        end
      end
    end

    context 'when the parameters are invalid' do
      context 'because they are missing' do
        let(:override_value) { nil }

        it 're-renders the confirmation page' do
          expect(response).to render_template(:confirmation)
        end
      end

      context 'because a reason is not supplied' do
        let(:override_value) { 'other' }

        it 're-renders the confirmation page' do
          expect(response).to render_template(:confirmation)
        end
      end
    end
  end

  context 'GET #confirmation' do
    before { get :confirmation, application_id: application.id }

    it 'displays the confirmation view' do
      expect(response).to render_template :confirmation
    end

    it 'assigns application' do
      expect(assigns(:application)).to eql(application)
    end

    it 'assigns confirm' do
      expect(assigns(:confirm)).to be_a_kind_of(Views::Confirmation::Result)
    end
  end

  context 'after an application is processed' do
    let!(:application) { create :application, :processed_state, office: user.office }

    describe 'when accessing the personal_details view' do
      before { get :personal_information, application_id: application.id }

      subject { response }

      it { is_expected.to have_http_status(:redirect) }

      it { is_expected.to redirect_to(processed_application_path(application)) }

      it 'is expected to set the flash message' do
        expect(flash[:alert]).to eql 'This application has been processed. You can’t edit any details.'
      end
    end
  end

  context 'after an application is deleted' do
    let!(:application) { create :application, :deleted_state, office: user.office }

    describe 'when accessing the personal_details view' do
      before { get :personal_information, application_id: application.id }

      subject { response }

      it { is_expected.to have_http_status(:redirect) }

      it { is_expected.to redirect_to(deleted_application_path(application)) }

      it 'is expected to set the flash message' do
        expect(flash[:alert]).to eql 'This application has been deleted. You can’t edit any details.'
      end
    end
  end

  context 'when an application is awaiting evidence' do
    let!(:application) { create :application, :waiting_for_evidence_state, office: user.office }
    let!(:evidence) { create :evidence_check, application: application }

    describe 'when accessing the personal_details view' do
      before { get :personal_information, application_id: application.id }

      subject { response }

      it { is_expected.to have_http_status(:redirect) }

      it { is_expected.to redirect_to(evidence_show_path(evidence)) }

      it 'is expected to set the flash message' do
        expect(flash[:alert]).to eql 'This application is waiting for evidence. You can’t edit any details.'
      end
    end
  end

  context 'when an application is part_payment' do
    let(:application) { create :application, :waiting_for_part_payment_state, office: user.office }
    let!(:part_payment) { create(:part_payment, application: application) }

    describe 'when accessing the personal_details view' do
      before { get :personal_information, application_id: application.id }

      subject { response }

      it { is_expected.to have_http_status(:redirect) }

      it { is_expected.to redirect_to(part_payment_path(part_payment)) }

      it 'is expected to set the flash message' do
        expect(flash[:alert]).to eql 'This application is waiting for part-payment. You can’t edit any details.'
      end
    end
  end
end
