require 'rails_helper'

RSpec.describe Applications::ProcessController, type: :controller do
  let(:user)          { create :user }
  let(:application) { build_stubbed(:application, office: user.office) }
  let(:dwp_monitor) { instance_double('DwpMonitor') }
  let(:dwp_state) { 'online' }

  before do
    sign_in user
    allow(Application).to receive(:find).with(application.id.to_s).and_return(application)

    allow(dwp_monitor).to receive(:state).and_return(dwp_state)
    allow(DwpMonitor).to receive(:new).and_return(dwp_monitor)
  end

  describe 'POST create' do
    let(:builder) { instance_double(ApplicationBuilder, build: application) }

    before do
      allow(ApplicationBuilder).to receive(:new).with(user).and_return(builder)
      allow(application).to receive(:save)

      post :create
    end

    it 'creates a new application' do
      expect(application).to have_received(:save)
    end

    it 'redirects to the personal information page for that application' do
      expect(response).to redirect_to(application_personal_informations_path(application))
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

      it 'assigns applicant' do
        expect(assigns(:applicant)).to be_a_kind_of(Views::Overview::Applicant)
      end

      it 'assigns details' do
        expect(assigns(:details)).to be_a_kind_of(Views::Overview::Details)
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
    let(:resolver) { instance_double(ResolverService, complete: nil) }

    context 'success' do
      before do
        allow(ResolverService).to receive(:new).with(application, user).and_return(resolver)

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

    context 'exception' do
      let(:exception) { ActiveRecord::RecordInvalid.new(application) }

      before do
        allow(ResolverService).to receive(:new).and_raise(exception)
      end

      def post_summary_save
        Timecop.freeze(current_time) do
          sign_in user
          post :summary_save, application_id: application.id
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
        allow(Raven).to receive(:capture_exception).with(exception, application_id: application.id)
        post_summary_save
      end
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

end
