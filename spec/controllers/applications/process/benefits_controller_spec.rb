require 'rails_helper'

RSpec.describe Applications::Process::BenefitsController do
  let(:user)          { create(:user) }
  let(:application) { build_stubbed(:application, office: user.office, detail: detail) }
  let(:detail) { build_stubbed(:detail, calculation_scheme: scheme) }
  let(:benefit_form) { instance_double(Forms::Application::Benefit) }
  let(:dwp_monitor) { instance_double(DwpMonitor) }
  let(:dwp_state) { 'online' }
  let(:scheme) { FeatureSwitching::CALCULATION_SCHEMAS[0].to_s }

  before do
    sign_in user
    allow(Application).to receive(:find).with(application.id.to_s).and_return(application)
    allow(Forms::Application::Benefit).to receive(:new).with(application).and_return(benefit_form)
    allow(dwp_monitor).to receive(:state).and_return(dwp_state)
    allow(DwpMonitor).to receive(:new).and_return(dwp_monitor)
  end

  describe 'GET #benefits' do
    let(:saving) { double }

    before do
      allow(application).to receive(:saving).and_return(saving)
      allow(saving).to receive(:passed?).and_return(savings_valid)

      get :index, params: { application_id: application.id }
    end

    context 'when application failed savings and investments' do
      let(:savings_valid) { false }

      it 'redirects to the summary' do
        expect(response).to redirect_to(application_summary_path(application))
      end
    end

    context 'when UCD changes apply' do
      let(:savings_valid) { false }
      let(:scheme) { FeatureSwitching::CALCULATION_SCHEMAS[1].to_s }

      it 'redirects to the summary' do
        expect(response).to render_template(:index)
      end
    end

    context 'when savings and investments passed' do
      let(:savings_valid) { true }

      it 'returns 200 response' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template(:index)
      end

      it 'assigns the benefits form' do
        expect(assigns(:form)).to eql(benefit_form)
      end

      describe '@status' do
        subject { assigns(:dwp_state) }

        context 'when the dwp is up' do
          it { is_expected.to eql(dwp_state) }
        end

        context 'when the dwp is down' do
          let(:dwp_state) { 'offline' }

          it { is_expected.to eql(dwp_state) }
        end
      end
    end
  end

  describe 'PUT #benefits_save' do
    let(:expected_params) { { benefits: 'false' } }
    let(:benefit_form) { instance_double(Forms::Application::Benefit, benefits: user_says_on_benefits) }
    let(:dwp_warning) { instance_double(DwpWarning, check_state: dwp_warning_check_state) }
    let(:user_says_on_benefits) { false }
    let(:dwp_warning_check_state) { 'online' }
    let(:benefit_check_runner) { instance_double(BenefitCheckRunner, run: nil) }
    let(:valid_for_paper_evidence) { true }

    before do
      allow(benefit_form).to receive(:update).with(expected_params)
      allow(benefit_form).to receive(:save).and_return(form_save)
      allow(BenefitCheckRunner).to receive(:new).with(application).and_return(benefit_check_runner)
      allow(application).to receive_messages(allow_benefit_check_override?: valid_for_paper_evidence)
      allow(DwpWarning).to receive(:order).and_return([dwp_warning, 'test'])

      post :create, params: { application_id: application.id, application: expected_params }
    end

    context 'when the form can be saved' do
      let(:form_save) { true }

      context 'when the applicant says they are on benefits' do
        let(:user_says_on_benefits) { true }

        it 'runs the benefit check on the application' do
          expect(benefit_check_runner).to have_received(:run)
        end

        context 'when the dwp_warning_check_state is offline do not call benefit check' do
          let(:dwp_warning_check_state) { 'offline' }

          it 'does not run the benefit check on the application' do
            expect(benefit_check_runner).not_to have_received(:run)
          end

          it 'redirects to the benefits override page' do
            expect(response).to redirect_to(application_benefit_override_paper_evidence_path(application))
          end
        end

        context 'when the dwp_warning_check_state is online call benefit check' do
          let(:dwp_warning_check_state) { 'online' }

          it 'does run the benefit check on the application' do
            expect(benefit_check_runner).to have_received(:run)
          end
        end

        context 'when the dwp_warning_check_state is default_checker call benefit check' do
          let(:dwp_warning_check_state) { 'default_checker' }

          it 'does not run the benefit check on the application' do
            expect(benefit_check_runner).to have_received(:run)
          end
        end

        context 'when the benefit check response is valid for paper evidence' do
          let(:valid_for_paper_evidence) { true }
          it 'redirects to the benefits override page' do
            expect(response).to redirect_to(application_benefit_override_paper_evidence_path(application))
          end
        end
      end

      context 'when the applicant says they are not on benefits' do
        let(:user_says_on_benefits) { false }

        it 'does not run benefit check on the application' do
          expect(benefit_check_runner).not_to have_received(:run)
        end

        it 'redirects to the dependents page' do
          expect(response).to redirect_to(application_dependents_path(application))
        end

        context "it's refund" do
          let(:detail) { build_stubbed(:detail, refund: true) }

          it "still goes to dependents page" do
            expect(response).to redirect_to(application_dependents_path(application))
          end
        end
      end
    end

    context 'when the form can\'t be saved' do
      let(:form_save) { false }

      it 'renders the correct template' do
        expect(response).to render_template(:index)
      end

      it 'assigns the benefits form' do
        expect(assigns(:form)).to eql(benefit_form)
      end
    end
  end
end
