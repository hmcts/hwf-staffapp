require 'rails_helper'

RSpec.describe EvidenceController, type: :controller do
  include Devise::TestHelpers

  let(:user) { create :user, office: create(:office) }
  let(:application) { create :application }
  let(:evidence) { create :evidence_check, application_id: application.id }

  before do
    allow(EvidenceCheck).to receive(:find).with(evidence.id.to_s).and_return(evidence)
  end

  describe 'GET #show' do
    context 'as a signed out user' do
      before(:each) { get :show, id: evidence.id }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(response).to redirect_to(user_session_path) }
    end

    context 'as a signed in user' do
      before do
        sign_in user
        get :show, id: evidence.id
      end

      it 'returns the correct status code' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template('show')
      end

      it 'assigns the overview model' do
        expect(assigns(:overview)).to be_a(Views::ApplicationOverview)
      end
    end
  end

  describe 'GET #accuracy' do
    context 'as a signed out user' do
      before(:each) { get :accuracy, id: evidence.id }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(response).to redirect_to(user_session_path) }
    end

    context 'as a signed in user' do
      before(:each) do
        allow(Forms::Evidence::Accuracy).to receive(:new).with(evidence).and_return(form)
        sign_in user
        get :accuracy, id: evidence.id
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
    let(:expected_form_params) { { correct: true, incorrect_reason: 'reason' } }

    context 'as a signed out user' do
      before(:each) { post :accuracy_save, id: evidence.id, evidence: expected_form_params }

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
        post :accuracy_save, id: evidence.id, evidence: expected_form_params
      end

      context 'when the form can be saved' do
        let(:form_save) { true }

        context 'when the form evidence is correct' do
          let(:form) { double(correct: true) }

          it 'redirects to the income page' do
            expect(response).to redirect_to(evidence_income_path(evidence))
          end
        end
        context 'when the form evidence is not correct' do
          let(:form) { double(correct: false) }

          it 'redirects to the income page' do
            expect(response).to redirect_to(evidence_summary_path(evidence))
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
      before(:each) { get :income, id: evidence.id }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(response).to redirect_to(user_session_path) }
    end

    context 'as a signed in user' do
      let(:form) { double }

      before do
        allow(Evidence::Forms::Income).to receive(:new).with(evidence).and_return(form)
        sign_in user
        get :income, id: evidence.id
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
      before(:each) { post :income_save, id: evidence.id, evidence: expected_form_params }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(response).to redirect_to(user_session_path) }
    end

    context 'as a signed in user' do
      let(:form) { double }

      before do
        allow(Evidence::Forms::Income).to receive(:new).with(evidence).and_return(form)
        allow(form).to receive(:update_attributes).with(expected_form_params)
        allow(form).to receive(:save).and_return(form_save)
        sign_in user
        post :income_save, id: evidence.id, evidence: expected_form_params
      end

      context 'when the form is filled in correctly' do
        let(:form_save) { true }
        it 'returns redirects to the result page' do
          expect(response).to redirect_to(evidence_result_path)
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
      before(:each) { get :result, id: evidence }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(response).to redirect_to(user_session_path) }
    end

    context 'as a signed in user' do
      before do
        sign_in user
        get :result, id: evidence
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
      before(:each) { get :summary, id: evidence }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(response).to redirect_to(user_session_path) }
    end

    context 'as a signed in user' do
      before do
        sign_in user
        get :summary, id: evidence
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
    let(:resolver) { double(complete: nil) }
    let(:evidence) { create :evidence_check }

    context 'as a signed out user' do
      before(:each) { post :summary_save, id: evidence }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(response).to redirect_to(user_session_path) }
    end

    context 'as a signed in user' do
      before(:each) do
        expect(ResolverService).to receive(:new).with(evidence, user).and_return(resolver)
        sign_in user
        post :summary_save, id: evidence
      end

      it 'redirects to the correct page' do
        expect(response).to redirect_to(evidence_confirmation_path)
      end

      it 'returns the correct status code' do
        expect(response.status).to eq 302
      end
    end
  end

  describe 'GET #confirmation' do
    context 'as a signed out user' do
      before(:each) { post :summary_save, id: evidence }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(response).to redirect_to(user_session_path) }
    end

    context 'as a signed in user' do
      before(:each) do
        sign_in user
        get :confirmation, id: evidence
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
    end
  end

  describe 'GET #return_letter' do
    context 'as a signed out user' do
      before(:each) { get :return_letter, id: evidence }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(response).to redirect_to(user_session_path) }
    end

    context 'as a signed in user' do
      before(:each) do
        sign_in user
        get :return_letter, id: evidence
      end

      it { expect(response).to have_http_status(200) }

      it { expect(response).to render_template('return_letter') }
    end
  end

  describe 'POST #return_application' do
    context 'as a signed out user' do
      before(:each) { post :return_application, id: evidence }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(response).to redirect_to(user_session_path) }
    end

    context 'as a signed in user' do
      before(:each) do
        sign_in user
        post :return_application, id: evidence
      end

      it 'returns the correct status code' do
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
