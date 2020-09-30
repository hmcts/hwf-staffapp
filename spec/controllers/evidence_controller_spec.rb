require 'rails_helper'

RSpec.describe EvidenceController, type: :controller do
  let(:office) { create(:office) }
  let(:user) { create :user, office: office }
  let(:applicant) { create :applicant_with_all_details }
  let(:application) { create :application, office: office, applicant: applicant }
  let(:evidence) { create :evidence_check, application_id: application.id }
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

      context 'processed evidence' do
        let(:evidence) { create :evidence_check, :completed, application_id: application.id }

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
        allow(form).to receive(:update_attributes).with(expected_form_params)
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
        allow(form).to receive(:update_attributes).with(expected_form_params)
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
          expect(response.status).to eq 302
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
        expect(response.status).to eq 302
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
      before do
        sign_in user
        get :confirmation, params: { id: evidence }
      end

      it 'returns the correct status code' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template('confirmation')
      end

      it 'assigns the evidence check as confirmation' do
        expect(assigns(:confirmation)).to eql(evidence)
      end

      context 'processed evidence' do
        let(:evidence) { create :evidence_check, :completed, application_id: application.id }

        it 'should not redirect to dashboard' do
          expect(response).not_to redirect_to(root_path)
        end

        it 'renders the correct template' do
          expect(response).to render_template('confirmation')
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
      let(:evidence) { create :evidence_check, :completed, application_id: application.id }

      before do
        sign_in user
        get :return_letter, params: { id: evidence }
      end

      it 'should redirect to dashboard' do
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'POST #return_application' do
    context 'as a signed out user' do
      before { post :return_application, params: { id: evidence } }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(response).to redirect_to(user_session_path) }
    end

    context 'as a signed in user' do
      before do
        sign_in user
        post :return_application, params: { id: evidence }
      end

      it 'returns the correct status code' do
        expect(response).to have_http_status(:redirect)
      end

      it 'does not calls the evidence_check_flag' do
        expect(evidence_check_flagging_service).not_to have_received(:process_flag)
      end
    end
  end
end
