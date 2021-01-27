require 'rails_helper'

RSpec.describe Applications::Process::BenefitsController, type: :controller do
  let(:user)          { create :user }
  let(:application) { build_stubbed(:application, office: user.office) }
  let(:benefit_form) { instance_double('Forms::Application::Benefit') }
  let(:dwp_monitor) { instance_double('DwpMonitor') }
  let(:dwp_state) { 'online' }

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
    let(:expected_params) { { 'benefits': 'false' } }
    let(:benefit_form) { instance_double(Forms::Application::Benefit, benefits: user_says_on_benefits) }
    let(:user_says_on_benefits) { false }
    let(:can_override) { false }
    let(:dwp_error?) { false }
    let(:benefit_check_runner) { instance_double(BenefitCheckRunner, run: nil, can_override?: can_override) }
    let(:benefit_override) { nil }

    before do
      allow(benefit_form).to receive(:update_attributes).with(expected_params)
      allow(benefit_form).to receive(:save).and_return(form_save)
      allow(BenefitCheckRunner).to receive(:new).with(application).and_return(benefit_check_runner)
      allow(application).to receive(:failed_because_dwp_error?).and_return dwp_error?
      allow(application).to receive(:benefit_override).and_return benefit_override
      allow(benefit_override).to receive(:destroy)

      post :create, params: { application_id: application.id, application: expected_params }
    end

    context 'when the form can be saved' do
      let(:form_save) { true }

      context 'when the applicant says they are on benefits' do
        let(:user_says_on_benefits) { true }

        it 'runs the benefit check on the application' do
          expect(benefit_check_runner).to have_received(:run)
        end

        context 'when the result can be overridden' do
          let(:can_override) { true }
          let(:benefit_override) { instance_double('BenefitOverride') }

          it 'redirects to the benefits override page' do
            expect(response).to redirect_to(application_benefit_override_paper_evidence_path(application))
          end

          it 'don not destroy benefit_override if exist' do
            expect(benefit_override).not_to have_received(:destroy)
          end

        end

        context 'when the result is failed because of DWP failed response' do
          let(:dwp_error?) { true }

          it 'redirects to the home page' do
            expect(response).to redirect_to(root_path)
          end

          it 'displays message' do
            message = "Processing benefit applications without paper evidence is not working at the moment. Try again later when the DWP checker is available."
            expect(flash['alert']).to eql(message)
          end
        end

        context 'when the result can not be overridden' do
          it 'redirects to the summary override page' do
            expect(response).to redirect_to(application_summary_path(application))
          end
        end
      end

      context 'when the applicant says they are not on benefits' do
        let(:user_says_on_benefits) { false }

        it 'does not run benefit check on the application' do
          expect(benefit_check_runner).not_to have_received(:run)
        end

        it 'redirects to the income page' do
          expect(response).to redirect_to(application_incomes_path(application))
        end

        context "it's refund" do
          let(:detail) { build_stubbed(:detail, refund: true) }

          it "still goes to income page" do
            expect(response).to redirect_to(application_incomes_path(application))
          end
        end

        context "it checks existing benefit override" do
          let(:benefit_override) { instance_double('BenefitOverride') }
          it 'destroy benefit_override if exist' do
            expect(benefit_override).to have_received(:destroy)
          end

          it "still goes to income page" do
            expect(response).to redirect_to(application_incomes_path(application))
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
