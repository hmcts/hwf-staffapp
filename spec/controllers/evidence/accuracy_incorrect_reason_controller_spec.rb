require 'rails_helper'

RSpec.describe Evidence::AccuracyIncorrectReasonController, type: :controller do
  let(:office) { create(:office) }
  let(:user) { create :user, office: office }
  let(:applicant) { application.applicant }
  let(:application) { create :application, :applicant_full, :waiting_for_evidence_state, office: office }
  let(:evidence) { application.evidence_check }

  before do
    allow(EvidenceCheck).to receive(:find).with(evidence.id.to_s).and_return(evidence)
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
    end
  end

  describe 'POST #update' do
    let(:expected_form_params) {
      { incorrect_reason_category: ["0", "0", "wrong_type_provided", "0", "pages_missing", "0"] }
    }

    context 'as a signed out user' do
      before { put :update, params: { id: evidence.id, evidence: expected_form_params } }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(response).to redirect_to(user_session_path) }
    end

    context 'as a signed in user' do
      let(:form) { double }
      let(:errors) { double }
      let(:formatted_params) { { incorrect_reason_category: ["wrong_type_provided", "pages_missing"] } }

      before do
        allow(Forms::Evidence::Accuracy).to receive(:new).with(evidence).and_return(form)
        allow(form).to receive(:update).with(formatted_params)
        allow(form).to receive(:save).and_return(form_save)
        allow(form).to receive(:errors).and_return(errors)
        allow(errors).to receive(:add)

        sign_in user
        put :update, params: { id: evidence.id, evidence: expected_form_params }
      end

      context 'when the form can be saved' do
        let(:form_save) { true }

        context 'when the form evidence is correct' do
          let(:form) { instance_double(Forms::Evidence::Accuracy, correct: true) }

          it 'redirects to the summary page' do
            expect(response).to redirect_to(summary_evidence_path(evidence))
          end
        end
      end

      context 'when the form can not be saved' do
        let(:form_save) { false }

        it 'assigns the form' do
          expect(assigns(:form)).to eql(form)
        end

        it 'renders the incorrect reason category page template again' do
          expect(response).to render_template(:show)
        end
      end

      context 'when the form is empty' do
        let(:expected_form_params) { {} }
        let(:form_save) { true }

        it 'renders the incorrect reason category page template again' do
          expect(response).to render_template(:show)
        end
      end
    end
  end

end
