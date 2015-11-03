require 'rails_helper'

RSpec.describe BenefitOverridesController, type: :controller do
  include Devise::TestHelpers

  let(:application) { create :application }
  let(:benefit_override) { build_stubbed(:benefit_override) }

  describe 'GET #paper_evidence' do
    before { get :paper_evidence, application_id: application.id }

    it { expect(response).to have_http_status(200) }

    it { expect(response).to render_template(:paper_evidence) }
  end

  describe 'POST #paper_evidence_save' do
    context 'when the data provided is correct' do
      let(:post_body) { { application_id: application.id, benefit_override: { correct: true } } }
      before { post :paper_evidence_save, post_body }

      it { expect(response).to have_http_status(302) }
    end

    context 'when the data provided is not correct' do
      it 'raises an exception when no parameters are passed in' do
        expect{
          post :paper_evidence_save, application_id: application.id
        }.to raise_error ActionController::ParameterMissing
      end

      it 'redirects to paper_evidence' do
        expect(
          post :paper_evidence_save, application_id: application.id, benefit_override: { correct: nil }
        ).to redirect_to(action: :paper_evidence)
      end
    end
  end
end
