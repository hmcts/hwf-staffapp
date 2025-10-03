require 'rails_helper'

RSpec.describe EvidenceController do
  let(:office) { create(:office) }
  let(:user) { create(:user, office: office) }
  let(:applicant) { application.applicant }
  let(:application) { create(:application, :applicant_full, :waiting_for_evidence_state, office: office) }
  let(:evidence) { application.evidence_check }

  let(:evidence_check_flagging_service) { double }

  before do
    allow(EvidenceCheck).to receive(:find).with(evidence.id.to_s).and_return(evidence)
    allow(EvidenceCheckFlaggingService).to receive(:new).with(evidence).and_return(evidence_check_flagging_service)
    allow(evidence_check_flagging_service).to receive(:can_be_flagged?).and_return(true)
    allow(evidence_check_flagging_service).to receive(:process_flag)
  end

  describe 'GET #show' do
    context 'as a signed out user' do
      before { get :show, params: { id: evidence.id } }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(response).to redirect_to(user_session_path) }
    end

    context 'as a signed in user' do

      context "success" do
        before do
          sign_in user
          get :show, params: { id: evidence.id }
        end

        it 'returns the correct status code' do
          expect(response).to have_http_status(200)
        end

        it 'renders the correct template' do
          expect(response).to render_template('show')
        end

        it 'assigns the details model' do
          expect(assigns(:details)).to be_a(Views::Overview::Details)
        end
      end

      context 'processed evidence' do
        before {
          sign_in user
          evidence.update(completed_at: Time.zone.yesterday, completed_by: user)
          get :show, params: { id: evidence.id }
        }

        it 'should redirect to dashboard' do
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end

  describe 'GET #accuracy' do
    context 'as a signed out user' do
      before { get :accuracy, params: { id: evidence.id } }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(response).to redirect_to(user_session_path) }
    end

    context 'as a signed in user' do
      before do
        allow(Forms::Evidence::Accuracy).to receive(:new).with(evidence).and_return(form)
        sign_in user
        get :accuracy, params: { id: evidence.id }
      end

      let(:form) { double }
      let(:expected_form_params) do
        {
          correct: evidence.correct,
          incorrect_reason: evidence.incorrect_reason
        }
      end

      it 'returns the correct status code' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template('accuracy')
      end

      it 'assigns the evidence form' do
        expect(assigns(:form)).to eql(form)
      end
    end
  end

  describe 'POST #accuracy_save' do
    let(:expected_form_params) { { correct: 'true', incorrect_reason: 'reason' } }

    context 'as a signed out user' do
      before { post :accuracy_save, params: { id: evidence.id, evidence: expected_form_params } }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(response).to redirect_to(user_session_path) }
    end

    context 'as a signed in user' do
      let(:form) { double }

      before do
        allow(Forms::Evidence::Accuracy).to receive(:new).with(evidence).and_return(form)
        allow(form).to receive(:update).with(expected_form_params)
        allow(form).to receive(:save).and_return(form_save)

        sign_in user
        post :accuracy_save, params: { id: evidence.id, evidence: expected_form_params }
      end

      context 'when the form can be saved' do
        let(:form_save) { true }

        context 'when the form evidence is correct' do
          let(:form) { instance_double(Forms::Evidence::Accuracy, correct: true) }

          it 'redirects to the income page' do
            expect(response).to redirect_to(income_evidence_path(evidence))
          end
        end
        context 'when the form evidence is not correct' do
          let(:form) { instance_double(Forms::Evidence::Accuracy, correct: false) }

          it 'redirects to the evidence incorrect reason page' do
            expect(response).to redirect_to(evidence_accuracy_incorrect_reason_path(evidence))
          end
        end
      end

      context 'when the form can not be saved' do
        let(:form_save) { false }

        it 'assigns the form' do
          expect(assigns(:form)).to eql(form)
        end

        it 'renders the accuracy template again' do
          expect(response).to render_template(:accuracy)
        end
      end
    end
  end

  describe 'GET #income' do
    context 'as a signed out user' do
      before { get :income, params: { id: evidence.id } }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(response).to redirect_to(user_session_path) }
    end

    context 'as a signed in user' do
      let(:form) { double }

      before do
        allow(Forms::Evidence::Income).to receive(:new).with(evidence).and_return(form)
        sign_in user
        get :income, params: { id: evidence.id }
      end

      it 'returns the correct status code' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template('income')
      end

      it 'assigns the income form' do
        expect(assigns(:form)).to eql(form)
      end
    end
  end

  describe 'POST #income_save' do
    let(:expected_form_params) { { income: '1000' } }

    context 'as a signed out user' do
      before { post :income_save, params: { id: evidence.id, evidence: expected_form_params } }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(response).to redirect_to(user_session_path) }
    end

    context 'as a signed in user' do
      let(:form) { double }

      before do
        allow(Forms::Evidence::Income).to receive(:new).with(evidence).and_return(form)
        allow(form).to receive(:update).with(expected_form_params)
        allow(form).to receive(:save).and_return(form_save)
        sign_in user
        post :income_save, params: { id: evidence.id, evidence: expected_form_params }
      end

      context 'when the form is filled in correctly' do
        let(:form_save) { true }
        it 'returns redirects to the result page' do
          expect(response).to redirect_to(result_evidence_path)
        end

        it 'returns the correct status code' do
          expect(response).to have_http_status 302
        end
      end

      context 'when the form is filled incorrectly' do
        let(:form_save) { false }

        it 're-renders the view' do
          expect(response).to render_template :income
        end
      end
    end
  end

  describe 'GET #result' do
    context 'as a signed out user' do
      before { get :result, params: { id: evidence } }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(response).to redirect_to(user_session_path) }
    end

    context 'as a signed in user' do
      before do
        sign_in user
        get :result, params: { id: evidence }
      end

      it 'returns the correct status code' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template :result
      end
    end
  end

  describe 'GET #summary' do
    context 'as a signed out user' do
      before { get :summary, params: { id: evidence } }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(response).to redirect_to(user_session_path) }
    end

    context 'as a signed in user' do
      before do
        sign_in user
        get :summary, params: { id: evidence }
      end

      it 'returns the correct status code' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template :summary
      end

      it { expect(assigns(:fee_status)).to be_an_instance_of(Views::Overview::FeeStatus) }
    end
  end

  describe 'POST #summary_save' do
    let(:resolver) { instance_double(ResolverService, complete: nil) }

    context 'as a signed out user' do
      before { post :summary_save, params: { id: evidence } }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(response).to redirect_to(user_session_path) }
    end

    context 'as a signed in user' do
      before do
        allow(ResolverService).to receive(:new).with(evidence, user).and_return(resolver)
        sign_in user
        post :summary_save, params: { id: evidence }
      end

      it 'redirects to the correct page' do
        expect(response).to redirect_to(confirmation_evidence_path)
      end

      it 'returns the correct status code' do
        expect(response).to have_http_status 302
      end

      it { expect(evidence_check_flagging_service).to have_received(:process_flag) }
    end
  end

  describe 'GET #confirmation' do
    context 'as a signed out user' do
      before { post :summary_save, params: { id: evidence } }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(response).to redirect_to(user_session_path) }
    end

    context 'as a signed in user' do
      context 'not completed' do
        before do
          sign_in user
          get :confirmation, params: { id: evidence }
        end

        it 'returns the correct status code' do
          expect(response).to have_http_status(200)
        end

        it 'renders the correct template' do
          expect(response).to render_template('applications/process/confirmation/index')
        end

        it { expect(assigns(:application)).to eql(evidence.application) }
        it { expect(assigns(:confirm)).to be_an_instance_of(Views::Confirmation::Result) }
        it { expect(assigns(:form)).to be_an_instance_of(Forms::Application::DecisionOverride) }
      end

      context 'processed evidence' do
        before {
          evidence.update(completed_at: Time.zone.yesterday, completed_by: user)
          sign_in user
          get :confirmation, params: { id: evidence }
        }

        it 'should not redirect to dashboard' do
          expect(response).not_to redirect_to(root_path)
        end

        it 'renders the correct template' do
          expect(response).to render_template('applications/process/confirmation/index')
        end
      end
    end
  end

  describe 'GET #return_letter' do
    context 'as a signed out user' do
      before { get :return_letter, params: { id: evidence } }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(response).to redirect_to(user_session_path) }
    end

    context 'as a signed in user' do
      before do
        sign_in user
        get :return_letter, params: { id: evidence }
      end

      it { expect(response).to have_http_status(200) }

      it { expect(response).to render_template('return_letter') }
    end

    context 'processed evidence' do
      before do
        evidence.update(completed_at: Time.zone.yesterday, completed_by: user)
        sign_in user
        get :return_letter, params: { id: evidence }
      end

      it 'should display return letter' do
        expect(response).to render_template('return_letter')
      end
    end
  end

  describe 'POST #return_application' do
    context 'when back to start param is present' do
      context 'as a signed out user' do
        before { post :return_application, params: { id: evidence, back_to_start: 'Back to start' } }

        it { expect(response).to have_http_status(:redirect) }

        it { expect(response).to redirect_to(user_session_path) }
      end

      context 'as a signed in user' do
        before do
          sign_in user
          post :return_application, params: { id: evidence, back_to_start: 'Back to start' }
        end

        it 'returns the correct status code' do
          expect(response).to have_http_status(:redirect)
        end

        it 'renders the dashboard page' do
          expect(response).to redirect_to(root_path)
        end

        it 'does not calls the evidence_check_flag' do
          expect(evidence_check_flagging_service).not_to have_received(:process_flag)
        end
      end
    end

    context 'when back to list param is present' do
      context 'as a signed in user' do
        before do
          sign_in user
          post :return_application, params: { id: evidence, back_to_list: 'Back to list' }
        end

        it 'returns the correct status code' do
          expect(response).to have_http_status(:redirect)
        end

        it 'renders the evidence checks page' do
          expect(response).to redirect_to(evidence_checks_path)
        end
      end
    end
  end

  describe 'section helper' do
    describe '#build_sections' do
      let(:representative) { build(:representative) }

      before do
        sign_in user
        allow(Views::Overview::FeeStatus).to receive(:new)
        allow(Views::Overview::Applicant).to receive(:new)
        allow(Views::Overview::OnlineApplicant).to receive(:new)
        allow(Views::Overview::Children).to receive(:new)
        allow(Views::Overview::Application).to receive(:new)
        allow(Views::Overview::Details).to receive(:new)
        allow(Views::Overview::Declaration).to receive(:new)
        allow(Views::Overview::Representative).to receive(:new)
        allow(controller).to receive(:build_representative).and_return representative
        get :show, params: { id: evidence.id }
      end

      it 'prepare decorators' do
        expect(Views::Overview::FeeStatus).to have_received(:new).with(application)
        expect(Views::Overview::Applicant).to have_received(:new).with(application)
        expect(Views::Overview::OnlineApplicant).to have_received(:new).with(application)
        expect(Views::Overview::Children).to have_received(:new).with(application)
        expect(Views::Overview::Application).to have_received(:new).with(application)
        expect(Views::Overview::Details).to have_received(:new).with(application)
        expect(Views::Overview::Declaration).to have_received(:new).with(application)
        expect(Views::Overview::Representative).to have_received(:new).with(representative)
      end
    end

    context 'application' do
      let(:representative) { create(:representative, application: application) }

      it 'return representative' do
        representative
        new_representative = controller.build_representative(application)

        expect(new_representative.first_name).to eq(representative.first_name)
        expect(new_representative.last_name).to eq(representative.last_name)
        expect(new_representative.organisation).to eq(representative.organisation)
        expect(new_representative.position).to eq(representative.position)
      end
    end
  end
end
