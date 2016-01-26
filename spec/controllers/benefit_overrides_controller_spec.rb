require 'rails_helper'

RSpec.describe BenefitOverridesController, type: :controller do
  include Devise::TestHelpers

  let(:office) { create(:office) }
  let(:user) { create(:user, office: office) }
  let(:application) { build_stubbed :application, office: office }
  let(:benefit_override) { build_stubbed(:benefit_override, application: application) }
  let(:benefits_evidence_form) { double }

  before do
    expect(Application).to receive(:find).with(application.id.to_s).and_return(application)
    expect(BenefitOverride).to receive(:find_or_initialize_by).with(application: application).and_return(benefit_override)
    expect(Forms::BenefitsEvidence).to receive(:new).with(benefit_override).and_return(benefits_evidence_form)
    sign_in(user)
  end

  describe 'GET #paper_evidence' do
    before { get :paper_evidence, application_id: application.id }

    it { expect(response).to have_http_status(200) }

    it { expect(response).to render_template(:paper_evidence) }

    it 'assigns the form' do
      expect(assigns(:form)).to eql(benefits_evidence_form)
    end
  end

  describe 'POST #paper_evidence_save' do
    let(:override_params) { { evidence: false } }
    let(:params) { { application_id: application.id, benefit_override: override_params } }
    subject { post :paper_evidence_save, params }

    before do
      expect(benefits_evidence_form).to receive(:update_attributes).with(override_params)
      subject
    end

    context 'when the form is valid' do
      let(:benefits_evidence_form) { double(save: true) }

      it 'redirects to the summary page' do
        expect(response).to redirect_to(application_summary_path(application))
      end
    end

    context 'when the form is not valid' do
      let(:benefits_evidence_form) { double(save: false) }

      it 'assigns the form' do
        expect(assigns(:form)).to eql(benefits_evidence_form)
      end

      it 're-renders the correct template' do
        expect(response).to render_template(:paper_evidence)
      end
    end
  end
end
