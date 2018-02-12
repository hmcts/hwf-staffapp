require 'rails_helper'

RSpec.describe Applications::Process::OverrideController, type: :controller do
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

  describe 'PUT #update' do
    let!(:application) { create(:application, office: user.office) }
    let(:override_reason) { nil }
    let(:params) { { value: override_value, reason: override_reason, created_by_id: user.id } }

    before { put :update, application_id: application.id, application: params }

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
end