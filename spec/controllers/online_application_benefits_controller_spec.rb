require 'rails_helper'

RSpec.describe OnlineApplicationBenefitsController do
  let(:user) { create(:user) }
  let(:online_application) { build_stubbed(:online_application, benefits: false) }
  let(:jurisdiction) { build_stubbed(:jurisdiction) }
  let(:form) { double }
  let(:id) { online_application.id }
  let(:benefit_check) { nil }
  let(:dwp_down) { false }
  let(:dwp_warning) { create(:dwp_warning, check_state: dwp_warning_state) }
  let(:dwp_warning_state) { DwpWarning::STATES[:default_checker] }

  before do
    allow(OnlineApplication).to receive(:find).with(online_application.id.to_s).and_return(online_application)
    allow(online_application).to receive(:last_benefit_check).and_return(benefit_check)
    allow(OnlineApplication).to receive(:find).with('non-existent').and_raise(ActiveRecord::RecordNotFound)
    allow(Forms::OnlineApplication).to receive(:new).with(online_application).and_return(form)
    sign_in user
  end

  describe 'GET #edit' do
    before do
      get :edit, params: { id: id }
    end

    it 'renders the edit template' do
      expect(response).to render_template(:edit)
    end
  end

  describe 'GET #edit offline banner' do
    render_views

    let(:form) { Forms::OnlineApplication.new(online_application) }
    let(:banner_heading) { 'DWP evidence check is disabled' }
    let(:banner_message) { 'You will only be able to process this application if you have supporting evidence' }
    let(:benefit_check) { instance_double(BenefitCheck, dwp_result: 'Yes') }
    let(:benefit_check_runner) { instance_double(BenefitCheckRunner, can_run?: true) }

    before do
      allow(BenefitCheckRunner).to receive(:new).with(online_application).and_return(benefit_check_runner)
      dwp_warning
      get :edit, params: { id: id }
    end

    context 'when the DWP Warning is set to offline' do
      let(:dwp_warning_state) { DwpWarning::STATES[:offline] }

      it 'shows the bold banner heading' do
        expect(response.body).to include(banner_heading)
      end

      it 'explains supporting evidence is needed' do
        expect(response.body).to include(banner_message)
      end

      it 'still shows the before proceeding hint below the banner' do
        expect(response.body).to include('BEFORE PROCEEDING FURTHER')
      end

      context 'and the stored benefit check has an error' do
        let(:benefit_check) { instance_double(BenefitCheck, dwp_result: nil) }

        it 'shows only the disabled banner, not the failed check banner' do
          expect(response.body).to include(banner_heading)
          expect(response.body).not_to include('DWP evidence check has failed')
        end
      end
    end

    context 'when the DWP Warning is set to online' do
      let(:dwp_warning_state) { DwpWarning::STATES[:online] }

      it 'does not show the disabled banner' do
        expect(response.body).not_to include(banner_heading)
      end

      context 'and the stored benefit check has an error' do
        let(:benefit_check) { instance_double(BenefitCheck, dwp_result: nil) }

        it 'shows the failed check banner' do
          expect(response.body).to include('DWP evidence check has failed')
        end
      end
    end
  end

  describe 'POST #retry' do
    let(:online_runner) { instance_double(OnlineBenefitCheckRunner, run: nil) }

    before do
      allow(OnlineBenefitCheckRunner).to receive(:new).with(online_application).and_return(online_runner)
      allow(Settings).to receive(:dwp_retry_button_enabled).and_return(flag_enabled)
      post :retry, params: { id: id }
    end

    context 'when the retry flag is enabled' do
      let(:flag_enabled) { true }

      it 'runs the online benefit check' do
        expect(online_runner).to have_received(:run)
      end

      it 'redirects to the benefits edit page' do
        expect(response).to redirect_to(benefits_online_application_path(online_application))
      end
    end

    context 'when the retry flag is disabled' do
      let(:flag_enabled) { false }

      it 'does not run the benefit check' do
        expect(online_runner).not_to have_received(:run)
      end

      it 'returns 403 forbidden' do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'PUT #update' do
    let(:params) { { benefits_override: benefits_override.to_s, dwp_manual_decision: benefits_override.to_s } }

    before do
      allow(form).to receive(:update).with(params)
      allow(form).to receive(:save).and_return(form_save)
      allow(online_application).to receive_messages(
        benefits_override: benefits_override,
        update: true,
        failed_because_dwp_error?: dwp_down,
        benefit_check_with_error_message?: benefit_check_has_error
      )
      dwp_warning

      put :update, params: { id: id, online_application: params }
    end

    context 'when the form can be saved' do
      let(:form_save) { true }
      let(:benefit_check_has_error) { false }

      context 'when the paper evidence was provided' do
        let(:benefits_override) { true }

        it 'redirects to the summary page' do
          expect(response).to redirect_to(online_application_path(online_application))
        end
      end

      context 'when benefit check has error message' do
        let(:benefit_check_has_error) { true }
        let(:benefits_override) { false }

        it 'redirects to the home page' do
          expect(response).to redirect_to(root_path)
        end

        it 'sets the alert flash message' do
          expect(flash[:alert]).to eql I18n.t('error_messages.benefit_check.cannot_process_application')
        end

        context 'and paper evidence was provided' do
          let(:benefits_override) { true }

          it 'redirects to the summary page' do
            expect(response).to redirect_to(online_application_path(online_application))
          end

          it 'does not set alert flash message' do
            expect(flash[:alert]).to be_nil
          end
        end
      end

      context 'when DWP Warning is offline' do
        let(:dwp_warning_state) { DwpWarning::STATES[:offline] }
        let(:benefits_override) { false }
        let(:benefit_check_has_error) { false }

        it 'redirects to the summary page so staff can process the application' do
          expect(response).to redirect_to(online_application_path(online_application))
        end

        it 'does not set alert flash message' do
          expect(flash[:alert]).to be_nil
        end

        context 'and the benefit check has an error message' do
          let(:benefit_check_has_error) { true }

          it 'still redirects to the summary page' do
            expect(response).to redirect_to(online_application_path(online_application))
          end

          it 'does not set alert flash message' do
            expect(flash[:alert]).to be_nil
          end
        end

        context 'and paper evidence was provided' do
          let(:benefits_override) { true }

          it 'redirects to the summary page' do
            expect(response).to redirect_to(online_application_path(online_application))
          end

          it 'does not set alert flash message' do
            expect(flash[:alert]).to be_nil
          end
        end
      end

      context 'when DWP Warning is online' do
        let(:dwp_warning_state) { DwpWarning::STATES[:online] }
        let(:benefits_override) { false }
        let(:benefit_check_has_error) { false }

        it 'redirects to the summary page' do
          expect(response).to redirect_to(online_application_path(online_application))
        end

        it 'does not set alert flash message' do
          expect(flash[:alert]).to be_nil
        end
      end

      context 'benefit check was "No" not an error' do
        let(:dwp_down) { false }
        let(:benefits_override) { false }
        let(:benefit_check_has_error) { false }

        it { expect(response).to redirect_to(online_application_path(online_application)) }
      end
    end

    context 'when the form cannot be saved' do
      let(:form_save) { false }
      let(:benefits_override) { false }
      let(:benefit_check_has_error) { false }

      it 'renders the edit template' do
        expect(response).to render_template(:edit)
      end
    end
  end

end
