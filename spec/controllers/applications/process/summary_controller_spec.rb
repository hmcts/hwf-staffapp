require 'rails_helper'

RSpec.describe Applications::Process::SummaryController do
  let(:user)          { create(:user) }
  let(:application) { build_stubbed(:application, office: user.office) }
  let(:income_form) { instance_double(Forms::Application::Dependent) }
  let(:income_calculation_runner) { instance_double(IncomeCalculationRunner, run: nil) }
  let(:fee_status) { instance_double(Views::Overview::FeeStatus) }

  before do
    sign_in user
    allow(Application).to receive(:find).with(application.id.to_s).and_return(application)
    allow(Views::Overview::FeeStatus).to receive(:new).with(application).and_return(fee_status)
    allow(Forms::Application::Dependent).to receive(:new).with(application).and_return(income_form)
    allow(IncomeCalculationRunner).to receive(:new).with(application).and_return(income_calculation_runner)
  end

  describe 'GET #summary' do
    before do
      get :index, params: { application_id: application.id }
    end

    context 'when the application does exist' do
      it 'responds with 200' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template(:index)
      end

      it 'assigns fee_status' do
        expect(assigns(:fee_status)).to eql(fee_status)
      end

      it 'assigns application' do
        expect(assigns(:application)).to eql(application)
      end

      it 'assigns applicant' do
        expect(assigns(:applicant)).to be_a(Views::Overview::Applicant)
      end

      it 'assigns details' do
        expect(assigns(:details)).to be_a(Views::Overview::Details)
      end

      it 'assigns savings' do
        expect(assigns(:savings)).to be_a(Views::Overview::SavingsAndInvestments)
      end

      it 'assigns benefits' do
        expect(assigns(:benefits)).to be_a(Views::Overview::Benefits)
      end

      it 'assigns income' do
        expect(assigns(:income)).to be_a(Views::Overview::Income)
      end

      it 'assigns declaration' do
        expect(assigns(:declaration)).to be_a(Views::Overview::Declaration)
      end

      it 'assigns representative' do
        expect(assigns(:representative)).to be_a(Views::Overview::Representative)
      end
    end
  end

  describe 'POST #summary_save' do
    let(:current_time) { Time.zone.now }
    let(:user) { create(:user) }
    let(:application) { create(:application_full_remission, office: user.office) }
    let(:resolver) { instance_double(ResolverService, complete: nil) }

    context 'success' do
      before do
        allow(ResolverService).to receive(:new).with(application, user).and_return(resolver)

        travel_to(current_time) do
          sign_in user
          post :create, params: { application_id: application.id }
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

    context 'exception' do
      let(:exception) { ActiveRecord::RecordInvalid.new(application) }

      before do
        allow(ResolverService).to receive(:new).and_raise(exception)
      end

      def post_summary_save
        travel_to(current_time) do
          sign_in user
          post :create, params: { application_id: application.id }
        end
      end

      it 'catch exception and return error' do
        post_summary_save
        expect(flash[:alert]).to include('There was an issue creating the new record')
      end

      it 'redirect to previous page' do
        post_summary_save
        expect(response).to redirect_to(application_summary_path(application))
      end

      it 'catch exception and notify sentry' do
        allow(Sentry).to receive(:capture_message)
        post_summary_save
        expect(Sentry).to have_received(:capture_message).with(exception.message, extra: { application_id: application.id })
      end
    end

    describe 'only new aplications are processed' do
      before do
        sign_in user
        allow(ResolverService).to receive(:new)
      end

      context 'waiting_for_evidence_state' do
        let(:application) { build_stubbed(:application, :waiting_for_evidence_state, office: user.office) }

        it do
          post :create, params: { application_id: application.id }
          expect(ResolverService).not_to have_received(:new).with(application, user)
        end
      end

      context 'waiting_for_part_payment_state' do
        let(:application) { build_stubbed(:application, :waiting_for_part_payment_state, office: user.office) }

        it do
          post :create, params: { application_id: application.id }
          expect(ResolverService).not_to have_received(:new).with(application, user)
        end
      end

      context 'processed_state' do
        let(:application) { build_stubbed(:application, :processed_state, office: user.office) }

        it do
          post :create, params: { application_id: application.id }
          expect(ResolverService).not_to have_received(:new).with(application, user)
        end
      end
    end
  end

end
