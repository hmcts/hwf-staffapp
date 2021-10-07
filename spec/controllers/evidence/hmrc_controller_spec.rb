require 'rails_helper'

RSpec.describe Evidence::HmrcController, type: :controller do
  let(:office) { create(:office) }
  let(:user) { create :user, office: office }
  let(:applicant) { create :applicant_with_all_details }
  let(:application) { create :application, office: office, applicant: applicant, created_at: '15.3.2021' }
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
        allow(form).to receive(:from_date_day=)
        allow(form).to receive(:from_date_month=)
        allow(form).to receive(:from_date_year=)
        allow(form).to receive(:to_date_day=)
        allow(form).to receive(:to_date_month=)
        allow(form).to receive(:to_date_year=)
      end

      it 'returns the correct status code' do
        get :new, params: { evidence_check_id: evidence.id }
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        get :new, params: { evidence_check_id: evidence.id }
        expect(response).to render_template('new')
      end

      it 'load form' do
        get :new, params: { evidence_check_id: evidence.id }
        expect(Forms::Evidence::HmrcCheck).to have_received(:new)
      end

      describe 'default date range' do
        # let(:application) { create :application, created_at: '15.3.2021' }
        # let(:evidence) { create :evidence_check, application: application }
        # subject(:form) { described_class.new(HmrcCheck.new(evidence_check: evidence)) }
        before do
          get :new, params: { evidence_check_id: evidence.id }
        end

        it { expect(form).to have_received(:from_date_day=).with 1 }
        it { expect(form).to have_received(:from_date_month=).with 2 }
        it { expect(form).to have_received(:from_date_year=).with 2021 }
        it { expect(form).to have_received(:to_date_day=).with 28 }
        it { expect(form).to have_received(:to_date_month=).with 2 }
        it { expect(form).to have_received(:to_date_year=).with 2021 }
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
        end

        it 'validate' do
          post_call
          expect(form).to have_received(:valid?)
        end

        describe 'service call' do
          context 'success' do
            before { post_call }

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
            let(:errors) { instance_double(ActiveModel::Errors) }
            before do
              allow(api_service).to receive(:income).and_raise(HwfHmrcApiError.new('Error message'))
              allow(form).to receive(:errors).and_return errors
              allow(errors).to receive(:add)
              post_call
            end

            it 'add error' do
              expect(errors).to have_received(:add).with(:request, 'Error message')
            end

            it 'render new template' do
              expect(response).to render_template('new')
            end
          end

          context 'fail - timeout' do
            let(:errors) { instance_double(ActiveModel::Errors) }
            before do
              allow(api_service).to receive(:income).and_raise(Net::ReadTimeout.new('Error message'))
              allow(form).to receive(:errors).and_return errors
              allow(errors).to receive(:add)
              post_call
            end

            it 'add error' do
              expect(errors).to have_received(:add).with(:timout, 'HMRC income checking failed. Submit this form for HMRC income checking')
            end

            it 'render new template' do
              expect(response).to render_template('new')
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
      context 'success' do
        before do
          allow(HmrcCheck).to receive(:find).and_return hmrc_check
          allow(hmrc_check).to receive(:total_income).and_return 100
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

      context 'data issue' do
        let(:errors) { instance_double(ActiveModel::Errors) }
        before do
          allow(HmrcCheck).to receive(:find).and_return hmrc_check
          allow(hmrc_check).to receive(:total_income).and_return 0
          allow(hmrc_check).to receive(:errors).and_return errors
          allow(errors).to receive(:add)
          sign_in user
          get :show, params: { evidence_check_id: evidence.id, id: hmrc_check.id }
        end

        it 'add error message' do
          message = "There might be an issue with HMRC data. Please contact technical support."
          expect(errors).to have_received(:add).with(:income_calculation, message)
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

  describe 'PUT #edit' do
    context 'as a signed out user' do
      before { put :update, params: { evidence_check_id: evidence.id, id: hmrc_check.id } }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(response).to redirect_to(user_session_path) }
    end

    context 'as a signed in user' do
      context 'no additional_income' do
        let(:put_params) { { hmrc_check: { "additional_income" => "false" }, evidence_check_id: evidence.id, id: hmrc_check.id } }
        before do
          allow(HmrcCheck).to receive(:find).and_return hmrc_check
          sign_in user
          put :update, params: put_params
        end

        it { expect(response).to redirect_to(evidence_check_hmrc_summary_path(evidence, hmrc_check)) }

        it 'load check' do
          expect(HmrcCheck).to have_received(:find).with(hmrc_check.id.to_s)
        end
      end

      context 'additional_income' do
        let(:amount) { '1' }
        let(:income_params) { { "additional_income" => "true", "additional_income_amount" => amount } }
        let(:put_params) { { hmrc_check: income_params, evidence_check_id: evidence.id, id: hmrc_check.id } }
        let(:update_return) { true }
        before do
          sign_in user
          allow(HmrcCheck).to receive(:find).and_return hmrc_check
          allow(hmrc_check).to receive(:update).and_return update_return
          put :update, params: put_params
        end

        context 'valid amount' do
          it { expect(response).to redirect_to(evidence_check_hmrc_summary_path(evidence, hmrc_check)) }
          it 'updates amount' do
            expect(hmrc_check).to have_received(:update).with(additional_income: '1')
          end
        end

        context 'invalid amount' do
          let(:update_return) { false }
          let(:amount) { 'asd' }
          it { expect(response).to render_template('show') }
        end

        it 'load check' do
          expect(HmrcCheck).to have_received(:find).with(hmrc_check.id.to_s)
        end
      end
    end
  end

end
