require 'rails_helper'

RSpec.describe BenefitOverridesController do
  let(:office) { create(:office) }
  let(:user) { create(:user, office: office) }
  let(:application) { build_stubbed(:application, office: office, detail: detail) }
  let(:detail) { build_stubbed(:detail, calculation_scheme: calculation_scheme) }
  let(:benefit_override) { build_stubbed(:benefit_override, application: application) }
  let(:benefits_evidence_form) { double }
  let(:calculation_scheme) { FeatureSwitching::CALCULATION_SCHEMAS[0] }

  before do
    allow(Application).to receive(:find).with(application.id.to_s).and_return(application)
    allow(BenefitOverride).to receive(:find_or_initialize_by).with(application: application).and_return(benefit_override)
    allow(Forms::BenefitsEvidence).to receive(:new).with(benefit_override).and_return(benefits_evidence_form)
    sign_in(user)
  end

  describe 'GET #paper_evidence' do
    before { get :paper_evidence, params: { application_id: application.id } }

    it { expect(response).to have_http_status(200) }

    it { expect(response).to render_template(:paper_evidence) }

    it 'assigns the form' do
      expect(assigns(:form)).to eql(benefits_evidence_form)
    end
  end

  describe 'POST #paper_evidence_save' do
    subject(:post_save) { post :paper_evidence_save, params: params }

    let(:override_params) { { evidence: 'false' } }
    let(:params) { { application_id: application.id, benefit_override: override_params } }
    let(:dwp_state) { 'online' }
    let(:monitor) { instance_double(DwpMonitor) }
    let(:dwp_warning) { create(:dwp_warning, check_state: dwp_warning_state) }
    let(:dwp_warning_state) { DwpWarning::STATES[:default_checker] }

    before do
      allow(benefits_evidence_form).to receive(:update).with(override_params)
      allow(DwpMonitor).to receive(:new).and_return monitor
      allow(monitor).to receive(:state).and_return dwp_state
      allow(DwpWarning).to receive(:state).and_return dwp_warning_state
      post_save
    end

    context 'when the form is valid' do
      let(:benefits_evidence_form) { instance_double(Forms::BenefitsEvidence, save: true) }

      context 'when the DWP is down' do
        context 'and the answer is yes' do
          context 'PRE UCD' do
            let(:calculation_scheme) { FeatureSwitching::CALCULATION_SCHEMAS[0] }
            it 'redirects to the summary page' do
              expect(response).to redirect_to(application_summary_path(application))
            end
          end
          context 'POST UCD' do
            let(:calculation_scheme) { FeatureSwitching::CALCULATION_SCHEMAS[1] }
            it 'redirects to the declaration page' do
              expect(response).to redirect_to(application_declaration_path(application))
            end
          end
        end

        context 'and the answer is no' do
          let(:dwp_state) { 'offline' }

          context 'PRE UCD' do
            let(:calculation_scheme) { FeatureSwitching::CALCULATION_SCHEMAS[0] }
            it 'redirects to the summary page' do
              expect(response).to redirect_to(application_summary_path(application))
            end
          end
          context 'POST UCD' do
            let(:calculation_scheme) { FeatureSwitching::CALCULATION_SCHEMAS[1] }
            it 'redirects to the declaration page' do
              expect(response).to redirect_to(application_declaration_path(application))
            end
          end

          # it 'redirects to the home page' do
          #   expect(response).to redirect_to(root_path)
          # end

          # it 'sets the alert flash message' do
          #   expect(flash[:alert]).to eql I18n.t('error_messages.benefit_check.cannot_process_application')
          # end

          # it 'Does not create save the form' do
          #   expect(benefits_evidence_form).not_to have_received(:save)
          # end

          # context 'and DWP Warning is set to default_checker' do
          #   let(:dwp_warning_state) { DwpWarning::STATES[:default_checker] }

          #   it 'redirects to the home page' do
          #     expect(response).to redirect_to(root_path)
          #   end
          # end

          context 'and DWP Warning is set to online' do
            let(:dwp_warning_state) { DwpWarning::STATES[:online] }

            context 'PRE UCD' do
              let(:calculation_scheme) { FeatureSwitching::CALCULATION_SCHEMAS[0] }
              it 'redirects to the summary page' do
                expect(response).to redirect_to(application_summary_path(application))
              end
            end
            context 'POST UCD' do
              let(:calculation_scheme) { FeatureSwitching::CALCULATION_SCHEMAS[1] }
              it 'redirects to the declaration page' do
                expect(response).to redirect_to(application_declaration_path(application))
              end
            end
          end

          # context 'and DWP Warning is set to offline' do
          #   let(:dwp_warning_state) { DwpWarning::STATES[:offline] }

          #   it 'redirects to the home page' do
          #     expect(response).to redirect_to(root_path)
          #   end
          # end

        end
      end
    end

    context 'when the form is not valid' do
      let(:benefits_evidence_form) { instance_double(Forms::BenefitsEvidence, save: false) }

      it 'assigns the form' do
        expect(assigns(:form)).to eql(benefits_evidence_form)
      end

      it 're-renders the correct template' do
        expect(response).to render_template(:paper_evidence)
      end
    end
  end
end
