require 'rails_helper'

RSpec.describe Evidence::AccuracyFailedReasonController, type: :controller do
  let(:office) { create(:office) }
  let(:user) { create :user, office: office }
  let(:applicant) { create :applicant_with_all_details }
  let(:application) { create :application, office: office, applicant: applicant }
  let(:evidence) { create :evidence_check, application_id: application.id }

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
      { incorrect_reason: "no_evidence", correct: false }
    }

    context 'as a signed out user' do
      before { put :update, params: { id: evidence.id, evidence: expected_form_params } }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(response).to redirect_to(user_session_path) }
    end

    context 'as a signed in user' do
      let(:form) { double }
      let(:errors) { double }

      before do
        allow(Forms::Evidence::Accuracy).to receive(:new).with(evidence).and_return(form)
        allow(form).to receive(:update_attributes).with(expected_form_params)
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
            expect(response).to redirect_to(return_letter_evidence_path(evidence))
          end
        end
      end

      context 'when the form can not be saved' do
        let(:form_save) { false }

        it 'assigns the form' do
          expect(assigns(:form)).to eql(form)
        end

        it 'renders the incorrect reason page template again' do
          expect(response).to render_template(:show)
        end
      end

      context 'when the form is empty' do
        let(:expected_form_params) { { correct: false } }
        let(:form_save) { true }

        it 'renders the incorrect reason page template again' do
          expect(response).to render_template(:show)
        end

        context 'emtpy staff error details' do
          let(:expected_form_params) {
            { incorrect_reason: 'staff_error', staff_error_details: '', correct: false }
          }
          let(:form_save) { true }

          it 'renders the incorrect reason page template again' do
            expect(response).to render_template(:show)
          end
        end

        context 'staff error details with a content' do
          let(:expected_form_params) {
            { incorrect_reason: 'staff_error', staff_error_details: 'wrong ref', correct: false }
          }
          let(:form_save) { true }

          it 'renders the incorrect reason page template again' do
            expect(response).to redirect_to(return_letter_evidence_path(evidence))
          end
        end
      end
    end
  end

end
