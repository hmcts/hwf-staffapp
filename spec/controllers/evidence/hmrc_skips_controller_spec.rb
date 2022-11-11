require 'rails_helper'

RSpec.describe Evidence::HmrcSkipsController do
  let(:office) { create(:office) }
  let(:user) { create(:user, office: office) }
  let(:evidence) { create(:evidence_check, income_check_type: 'hmrc', application: application) }
  let(:application) { create(:application, user: user, office: office) }

  describe 'PUT #update' do
    context 'as a signed out user' do
      before { sign_in user }
      context 'success' do
        before { put :update, params: { evidence_check_id: evidence.id } }
        it { expect(evidence.reload.income_check_type).to eq('paper') }
        it { expect(response).to redirect_to(evidence_check_path(evidence)) }
      end

      context 'fail' do
        let(:evidence) { build(:evidence_check, application: application, expires_at: nil, id: 123) }
        before {
          allow(EvidenceCheck).to receive(:find).and_return evidence
          put :update, params: { evidence_check_id: 123 }
        }

        it { expect(response).to redirect_to(new_evidence_check_hmrc_path(evidence)) }
      end
    end
  end
end
