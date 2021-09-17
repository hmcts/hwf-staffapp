require 'rails_helper'

RSpec.describe Evidence::HmrcController, type: :controller do
  let(:office) { create(:office) }
  let(:user) { create :user, office: office }
  let(:applicant) { create :applicant_with_all_details }
  let(:application) { create :application, office: office, applicant: applicant }
  let(:evidence) { create :evidence_check, application_id: application.id }
  let(:hmrc_check) { create :hmrc_check, evidence_check: evidence }

  before do
    allow(EvidenceCheck).to receive(:find).with(evidence.id.to_s).and_return(evidence)
  end

  describe 'GET #new' do
    context 'as a signed out user' do
      before { get :new, params: { evidence_check_id: evidence.id } }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(response).to redirect_to(user_session_path) }
    end

    context 'as a signed in user' do
      let(:form) { instance_double(Forms::Evidence::HmrcCheck) }
      before do
        sign_in user
        allow(Forms::Evidence::HmrcCheck).to receive(:new).and_return form
        get :new, params: { evidence_check_id: evidence.id }
      end

      it 'returns the correct status code' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template('new')
      end

      it 'load form' do
        expect(Forms::Evidence::HmrcCheck).to have_received(:new)
      end
    end
  end

  describe 'POST #create' do
    context 'as a signed out user' do
      before { post :create, params: { evidence_check_id: evidence.id } }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(response).to redirect_to(user_session_path) }
    end

    context 'as a signed in user' do
      let(:form) { instance_double(Forms::Evidence::HmrcCheck) }
      let(:api_service) { instance_double(HmrcApiService) }
      let(:hmrc_check) { instance_double(HmrcCheck) }

      let(:dates) {
        {
          "from_date_day" => '1',
          "from_date_month" => '2',
          "from_date_year" => '2000',
          "to_date_day" => '1',
          "to_date_month" => '2',
          "to_date_year" => '2001'
        }
      }
      let(:valid) { false }
      let(:post_call) { post :create, params: { evidence_check_id: evidence.id, hmrc_check: dates } }

      before do
        sign_in user
        allow(Forms::Evidence::HmrcCheck).to receive(:new).and_return form
        allow(form).to receive(:update_attributes)
        allow(form).to receive(:valid?).and_return valid
      end

      it 'update params' do
        post_call
        expect(form).to have_received(:update_attributes).with(dates)
      end

      context 'not valid' do
        it 'render new page again' do
          post_call
          expect(Forms::Evidence::HmrcCheck).to have_received(:new)
        end
      end

      context 'valid' do
        let(:valid) { true }
        before do
          allow(form).to receive(:from_date).and_return '2001-01-03'
          allow(form).to receive(:to_date).and_return '2002-01-03'
          allow(HmrcApiService).to receive(:new).and_return api_service
          allow(api_service).to receive(:income)
          allow(api_service).to receive(:hmrc_check).and_return hmrc_check
          post_call
        end

        it 'validate' do
          expect(form).to have_received(:valid?)
        end

        describe 'service call' do
          context 'success' do
            it "calls service with application" do
              expect(HmrcApiService).to have_received(:new).with(application)
            end

            it "load income" do
              expect(api_service).to have_received(:income).with('2001-01-03', '2002-01-03')
            end

            it "load hmrc_check" do
              expect(api_service).to have_received(:hmrc_check)
            end

            it "redirects to show page" do
              expect(response).to redirect_to(evidence_check_hmrc_path(evidence, hmrc_check))
            end
          end

          context 'fail' do
            it 'render new page again' do
              expect(Forms::Evidence::HmrcCheck).to have_received(:new)
            end
          end
        end
      end
    end
  end

  describe 'GET #show' do
    context 'as a signed out user' do
      before { get :show, params: { evidence_check_id: evidence.id, id: hmrc_check.id } }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(response).to redirect_to(user_session_path) }
    end

    context 'as a signed in user' do
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

      it 'load check' do
        expect(HmrcCheck).to have_received(:find).with(hmrc_check.id.to_s)
      end
    end
  end

end
