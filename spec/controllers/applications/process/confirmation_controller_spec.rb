require 'rails_helper'

RSpec.describe Applications::Process::ConfirmationController do
  let(:user)          { create(:user) }
  let(:application) { build_stubbed(:application, office: user.office) }
  let(:dwp_monitor) { instance_double(DwpMonitor) }
  let(:dwp_state) { 'online' }

  before do
    sign_in user
    allow(Application).to receive(:find).with(application.id.to_s).and_return(application)

    allow(dwp_monitor).to receive(:state).and_return(dwp_state)
    allow(DwpMonitor).to receive(:new).and_return(dwp_monitor)
  end

  context 'GET #index' do
    before { get :index, params: { application_id: application.id, type: 'paper' } }

    it 'displays the confirmation view' do
      expect(response).to render_template :index
    end

    it 'assigns application' do
      expect(assigns(:application)).to eql(application)
    end

    it 'assigns confirm' do
      expect(assigns(:confirm)).to be_a(Views::Confirmation::Result)
    end

    context 'evidence check' do
      let(:application) { create(:application, :waiting_for_evidence_state, office: user.office) }

      it 'redirects to the evidence check summary page' do
        expect(response).to redirect_to(evidence_check_path(application.evidence_check.id))
      end

      context 'hmrc income check' do
        let(:application) {
          build_stubbed(:application, :waiting_for_evidence_state,
                        office: user.office, evidence_check: evidence_check, medium: 'digital', income_period: income_period)
        }
        let(:evidence_check) { build_stubbed(:evidence_check, income_check_type: 'hmrc') }
        let(:income_period) { nil }

        it 'redirects to the hmrc check page' do
          expect(response).to redirect_to(new_evidence_check_hmrc_path(application.evidence_check.id))
        end

        context 'average income period' do
          let(:income_period) { 'average' }
          it 'redirects to the hmrc check page' do
            expect(response).to redirect_to(evidence_check_path(application.evidence_check.id))
          end
        end

        context 'last month income period' do
          let(:income_period) { 'last_month' }
          it 'redirects to the hmrc check page' do
            expect(response).to redirect_to(new_evidence_check_hmrc_path(application.evidence_check.id))
          end
        end
      end
    end
  end

end
