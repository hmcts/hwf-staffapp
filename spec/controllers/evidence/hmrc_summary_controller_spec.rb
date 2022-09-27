require 'rails_helper'

RSpec.describe Evidence::HmrcSummaryController, type: :controller do

  let(:office) { create(:office) }
  let(:user) { create :user, office: office }

  let(:applicant) { application.applicant }
  let(:application) { create :application, :applicant_full, :waiting_for_evidence_state, office: office, created_at: '15.3.2021' }
  let(:evidence) { application.evidence_check }

  let(:hmrc_check) { create :hmrc_check, evidence_check: evidence }

  before do
    allow(EvidenceCheck).to receive(:find).with(evidence.id.to_s).and_return(evidence)
  end

  describe 'GET #show' do
    context 'as a signed out user' do
      before { get :show, params: { evidence_check_id: evidence.id, id: hmrc_check.id } }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(response).to redirect_to(user_session_path) }
    end

    context 'as a signed in user' do
      context 'success' do
        before do
          allow(HmrcCheck).to receive(:find).and_return hmrc_check
          sign_in user
          get :show, params: { evidence_check_id: evidence.id, id: hmrc_check.id }
        end

        it 'returns the correct status code' do
          expect(response).to have_http_status(200)
        end

        it 'renders the correct template' do
          expect(response).to render_template('show')
        end

        it 'load hmrc_check' do
          expect(HmrcCheck).to have_received(:find).with(hmrc_check.id.to_s)
        end

        it 'load evidence' do
          expect(EvidenceCheck).to have_received(:find).with(evidence.id.to_s)
        end
      end
    end
  end

  describe 'POST #complete' do
    context 'as a signed out user' do
      before { post :complete, params: { evidence_check_id: evidence.id, id: hmrc_check.id } }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(response).to redirect_to(user_session_path) }
    end

    context 'as a signed in user' do
      let(:resolver) { instance_double(ResolverService) }
      let(:flag_service) { instance_double(EvidenceCheckFlaggingService) }

      before do
        allow(HmrcCheck).to receive(:find).and_return hmrc_check
        allow(ResolverService).to receive(:new).and_return resolver
        allow(EvidenceCheckFlaggingService).to receive(:new).and_return flag_service
        allow(resolver).to receive(:complete)
        allow(flag_service).to receive(:process_flag)
        allow(flag_service).to receive(:can_be_flagged?).and_return true
        sign_in user
      end

      context 'success' do
        before do
          post :complete, params: { evidence_check_id: evidence.id, id: hmrc_check.id }
        end

        it 'load evidence' do
          expect(EvidenceCheck).to have_received(:find).with(evidence.id.to_s)
        end

        it { expect(flag_service).to have_received(:process_flag) }

        it 'renders the correct template' do
          expect(response).to render_template('applications/process/confirmation/index')
        end

        it { expect(assigns(:application)).to eql(evidence.application) }
        it { expect(assigns(:confirm)).to be_an_instance_of(Views::Confirmation::Result) }
        it { expect(assigns(:form)).to be_an_instance_of(Forms::Application::DecisionOverride) }
      end

      context 'can not be flagged' do
        before do
          allow(flag_service).to receive(:can_be_flagged?).and_return false
          post :complete, params: { evidence_check_id: evidence.id, id: hmrc_check.id }
        end
        it { expect(flag_service).not_to have_received(:process_flag) }
      end

      context 'fail' do
        before {
          allow(resolver).to receive(:complete).and_raise(ResolverService::UndefinedOutcome)
          post :complete, params: { evidence_check_id: evidence.id, id: hmrc_check.id }
        }

        it 'render show tamplate with' do
          expect(response).to render_template('show')
        end

        it 'fills in error message' do
          expect(flash[:alert]).to eql('Undefined evidence check outcome, please contact support')
        end
      end
    end
  end
end
