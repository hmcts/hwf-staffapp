require 'rails_helper'

RSpec.describe OnlineApplicationsController do
  let(:user) { create(:user) }
  let(:online_application) { build_stubbed(:online_application, benefits: false) }
  let(:jurisdiction) { build_stubbed(:jurisdiction) }
  let(:form) { double }

  before do
    allow(OnlineApplication).to receive(:find).with(online_application.id.to_s).and_return(online_application)
    allow(OnlineApplication).to receive(:find).with('non-existent').and_raise(ActiveRecord::RecordNotFound)
    allow(Forms::OnlineApplication).to receive(:new).with(online_application).and_return(form)
    sign_in user
  end

  describe 'GET #edit' do
    let(:params) { { jurisdiction_id: user.jurisdiction_id } }
    before do
      allow(form).to receive(:enable_default_jurisdiction).with(user)
      allow(form).to receive(:jurisdiction_id).and_return(user.jurisdiction_id)
      get :edit, params: { id: id }
    end

    context 'when no online application is found with the id' do
      let(:id) { 'non-existent' }

      it 'redirects to the homepage' do
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when an online application is found with the id' do
      let(:id) { online_application.id }

      it 'renders the edit template' do
        expect(response).to render_template(:edit)
      end

      it 'assigns the edit form' do
        expect(assigns(:form)).to eql(form)
      end

      it 'assigns the online_application' do
        expect(assigns(:online_application)).to eql(online_application)
      end

      it 'assigns the user\'s office jurisdictions' do
        expect(assigns(:jurisdictions)).to eq(user.office.jurisdictions)
      end

      it 'sets the jurisdiction of the new object' do
        expect(assigns(:form).jurisdiction_id).to eq user.jurisdiction_id
      end

      context 'when the user does not have a default jurisdiction' do
        let(:user) { create(:user, jurisdiction_id: nil) }

        it 'sets the jurisdiction of the new object' do
          expect(assigns(:form).jurisdiction_id).to be_nil
        end
      end

      context 'when the Benefits Checker is down' do
        before do
          build_dwp_checks_with_bad_requests
          get :edit, params: { id: id }
        end

        context 'when it is an income based application' do
          let(:online_application) { build_stubbed(:online_application, :income) }

          it 'renders the edit template' do
            expect(response).to render_template(:edit)
          end
        end
      end
    end
  end

  describe 'PUT #update' do
    let(:params) { {} }
    let(:form_save) { false }
    let(:fee) { 500 }
    let(:dwp_state) { 'online' }
    let(:monitor) { instance_double(DwpMonitor) }
    let(:dwp_warning) { create(:dwp_warning, check_state: dwp_warning_state) }
    let(:dwp_warning_state) { DwpWarning::STATES[:default_checker] }
    let(:online_bc_runner) { instance_double(OnlineBenefitCheckRunner) }
    let(:online_bc) { instance_double(BenefitCheck, benefits_valid?: benefits_valid) }
    let(:benefits_valid) { true }
    let(:saving_outcome) { true }
    let(:saving_service) { instance_double(SavingsPassFailService) }

    before do
      allow(form).to receive(:update).with(params)
      allow(form).to receive_messages(save: form_save, fee: fee)
      allow(online_application).to receive_messages(update: true, last_benefit_check: online_bc)

      allow(DwpMonitor).to receive(:new).and_return monitor
      allow(monitor).to receive(:state).and_return dwp_state
      allow(DwpWarning).to receive(:state).and_return dwp_warning_state
      allow(OnlineBenefitCheckRunner).to receive(:new).and_return online_bc_runner
      allow(online_bc_runner).to receive(:run)
      allow(SavingsPassFailService).to receive(:new).and_return(saving_service)
      allow(saving_service).to receive(:calculate_online_application).and_return(saving_outcome)

      put :update, params: { id: id, online_application: params }
    end

    context 'when no online application is found with the id' do
      let(:id) { 'non-existent' }

      it 'redirects to the homepage' do
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when an online application is found with the id' do
      let(:id) { online_application.id }
      let(:params) { { fee: '100', jurisdiction_id: jurisdiction.id.to_s, user_id: user.id } }

      context 'when the form can be saved' do
        let(:form_save) { true }

        context 'when the fee is equal or less than £10,000' do
          it 'redirects to the summary page' do
            expect(response).to redirect_to(online_application_path(online_application))
          end
        end

        context 'when the fee is higher than £10,000' do
          let(:fee) { 15_000 }
          let(:params) { { fee: fee.to_s, user_id: user.id } }

          it 'redirects to the approval page' do
            expect(response).to redirect_to(approve_online_application_path(online_application))
          end
        end

        context 'when it is benefit application' do
          let(:online_application) { build_stubbed(:online_application, benefits: true) }

          context 'dwp is down' do
            let(:dwp_state) { 'offline' }

            it 'redirects to the approval page' do
              expect(response).to redirect_to(benefits_online_application_path(online_application))
            end

            context 'when the DwpWarning is set to online' do
              let(:dwp_warning_state) { DwpWarning::STATES[:online] }

              context 'run benefit check' do
                it 'does something' do
                  expect(online_bc_runner).to have_received(:run)
                end

                context 'benefit check is sucessfull' do
                  let(:benefits_valid) { true }

                  it 'redirects to the approval page' do
                    expect(response).to redirect_to(online_application_path(online_application))
                  end
                end

                context 'benefit check is not sucessfull' do
                  let(:benefits_valid) { false }

                  it 'redirects to the approval page' do
                    expect(response).to redirect_to(benefits_online_application_path(online_application))
                  end
                end

                context 'benefit check is nil' do
                  let(:benefits_valid) { nil }
                  it 'redirects to the approval page' do
                    expect(response).to redirect_to(benefits_online_application_path(online_application))
                  end
                end
              end
            end

            context 'when the DwpWarning is set to offline' do
              let(:dwp_warning_state) { DwpWarning::STATES[:offline] }

              it 'redirects to the approval page' do
                expect(response).to redirect_to(benefits_online_application_path(online_application))
              end
            end

            context 'when the DwpWarning is set to default' do
              let(:dwp_warning_state) { DwpWarning::STATES[:default_checker] }

              it 'redirects to the approval page' do
                expect(response).to redirect_to(benefits_online_application_path(online_application))
              end
            end
          end

          context 'dwp is working' do
            let(:dwp_state) { 'online' }

            it 'renders the summary page' do
              expect(response).to redirect_to(online_application_path(online_application))
            end
          end

          context 'saving fails' do
            let(:dwp_state) { 'offline' }
            let(:saving_outcome) { false }

            it 'renders the summary page' do
              expect(response).to redirect_to(online_application_path(online_application))
            end
          end

          context 'saving pass' do
            let(:dwp_state) { 'offline' }
            let(:dwp_warning_state) { DwpWarning::STATES[:offline] }

            it 'renders the summary page' do
              expect(response).to redirect_to(benefits_online_application_path(online_application))
            end
          end
        end
      end

      context 'when the form can not be saved' do
        it 'renders the edit template' do
          expect(response).to render_template(:edit)
        end

        it 'assigns the form' do
          expect(assigns(:form)).to eql(form)
        end

        it 'assigns the online_application' do
          expect(assigns(:online_application)).to eql(online_application)
        end

        it 'assigns the user\'s office jurisdictions' do
          expect(assigns(:jurisdictions)).to eq(user.office.jurisdictions)
        end
      end
    end
  end

  describe 'GET #show' do
    let(:overview) { double }

    before do
      allow(Views::Overview::Applicant).to receive(:new).with(online_application).and_return(overview)
      allow(Views::Overview::Application).to receive(:new).with(online_application).and_return(overview)
      allow(Views::Overview::Details).to receive(:new).with(online_application).and_return(overview)

      get :show, params: { id: id }
    end

    context 'when no online application is found with the id' do
      let(:id) { 'non-existent' }

      it 'redirects to the homepage' do
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when an online application is found with the id' do
      let(:id) { online_application.id }

      it 'renders the show template' do
        expect(response).to render_template(:show)
      end

      describe 'assigns the view models' do
        it { expect(assigns(:applicant)).to eql(overview) }
        it { expect(assigns(:application_view)).to eql(overview) }
        it { expect(assigns(:details)).to eql(overview) }
      end
    end
  end

  describe 'POST #complete' do
    let(:application) { build_stubbed(:application, office: user.office, detail: detail) }
    let(:detail) { build_stubbed(:detail) }
    let(:application_builder) { instance_double(ApplicationBuilder, build_from: application) }
    let(:application_calculation) { instance_double(ApplicationCalculation, run: nil) }
    let(:resolver_service) { instance_double(ResolverService, complete: nil) }
    let(:pass_fail_service) { instance_double(SavingsPassFailService, calculate!: nil) }
    let(:benefit_override) { build_stubbed(:benefit_override, application: application) }
    let(:dwp_error) { false }

    before do
      allow(ApplicationBuilder).to receive(:new).with(user).and_return(application_builder)
      allow(application).to receive(:save)
      allow(ApplicationCalculation).to receive(:new).with(application).and_return(application_calculation)
      allow(ResolverService).to receive(:new).with(application, user).and_return(resolver_service)
      allow(SavingsPassFailService).to receive(:new).with(application.saving).and_return(pass_fail_service)
      allow(BenefitOverride).to receive(:find_or_initialize_by).with(application: application).and_return benefit_override
      allow(benefit_override).to receive(:update)
      allow(application).to receive(:update)
      allow(application).to receive(:failed_because_dwp_error?).and_return(dwp_error)
      allow(detail).to receive(:update).and_return(true)

      post :complete, params: { id: id }
    end

    context 'when no online application is found with the id' do
      let(:id) { 'non-existent' }

      it 'redirects to the homepage' do
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when an online application is found with the id' do
      let(:id) { online_application.id }

      it 'builds the application' do
        expect(application_builder).to have_received(:build_from)
      end

      it 'runs the benefit / income calculation' do
        expect(application_calculation).to have_received(:run)
      end

      it 'runs the resolver service' do
        expect(resolver_service).to have_received(:complete)
      end

      it 'store schema used for calulation' do
        expect(detail).to have_received(:update).with(calculation_scheme: :prior_q4_23)
      end

      it 'runs the pass fail service' do
        expect(pass_fail_service).to have_received(:calculate!)
      end

      it 'redirects to the application confirmation page' do
        expect(response).to redirect_to(application_confirmation_path(application, 'digital'))
      end

      context 'benefit override true' do
        let(:online_application) { build_stubbed(:online_application, benefits_override: true) }

        it 'creates benefit overrides record' do
          expect(benefit_override).to have_received(:update).with(correct: true, completed_by: user)
        end

        it 'update outcome of the application' do
          expect(application).to have_received(:update).with(outcome: 'full')
        end
      end

      context 'benefit override false' do
        let(:online_application) { build_stubbed(:online_application, benefits_override: false) }

        it 'do not create benefit overrides record' do
          expect(benefit_override).not_to have_received(:update)
        end

        it 'do not update outcome' do
          expect(application).not_to have_received(:update)
        end
      end

      context 'benefit check with dwp error' do
        let(:dwp_error) { true }
        let(:online_application) { build_stubbed(:online_application, benefits_override: false) }

        it 'redirects to homepage' do
          expect(response).to redirect_to(root_path)
        end

        it 'displays error message' do
          message = "Processing benefit applications without paper evidence is not working at the moment. Try again later when the DWP checker is available."
          expect(flash[:alert]).to eql message
        end

        it 'do not run the resolver service' do
          expect(resolver_service).not_to have_received(:complete)
        end

        it 'no updates to the application' do
          expect(application).not_to have_received(:update)
        end

        context 'benefit overrides true' do
          let(:online_application) { build_stubbed(:online_application, benefits_override: true) }

          it 'do not run the resolver service' do
            expect(response).to redirect_to(application_confirmation_path(application, 'digital'))
          end
        end
      end

    end
  end

  context 'after an application is completed' do
    let(:online_application) { create(:online_application, :completed, :with_reference, convert_to_application: true) }

    describe 'when accessing the personal_details view' do
      before { get :edit, params: { id: online_application.id } }

      subject { response }

      it { is_expected.to have_http_status(:redirect) }

      it { is_expected.to redirect_to(application_confirmation_path(online_application.linked_application)) }

      it 'is expected to set the flash message' do
        expect(flash[:alert]).to eql 'This application has been processed. You can’t edit any details.'
      end
    end
  end

  context 'fee approval' do
    let(:form) { instance_double(Forms::FeeApproval) }

    before do
      allow(Forms::FeeApproval).to receive(:new).with(online_application).and_return(form)
    end

    describe 'GET #approve' do
      before do
        get :approve, params: { id: online_application.id }
      end

      it 'renders the edit template' do
        expect(response).to render_template(:approve)
      end

      it 'assigns the edit form' do
        expect(assigns(:form)).to eql(form)
      end

      it 'assigns the online_application' do
        expect(assigns(:online_application)).to eql(online_application)
      end
    end

    describe 'PUT #approve_save' do
      let(:params) { { fee_manager_firstname: 'Jane', fee_manager_lastname: 'Doe' } }

      before do
        allow(form).to receive(:update).with(params)
        allow(form).to receive(:save).and_return(form_save)

        put :approve_save, params: { id: online_application.id, online_application: params }
      end

      context 'when the form can be saved' do
        let(:form_save) { true }

        it 'redirects to the summary page' do
          expect(response).to redirect_to(online_application_path(online_application))
        end
      end

      context 'when the form can not be saved' do
        let(:form_save) { false }

        it 'renders the edit template' do
          expect(response).to render_template(:approve)
        end
      end
    end
  end
end
