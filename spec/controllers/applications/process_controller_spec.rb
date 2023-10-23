require 'rails_helper'

RSpec.describe Applications::ProcessController do
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

  describe 'POST create' do
    let(:builder) { instance_double(ApplicationBuilder, build: application) }
    let(:feature_switch_active) { false }

    before do
      allow(ApplicationBuilder).to receive(:new).with(user).and_return(builder)
      allow(application).to receive(:save)
      allow(FeatureSwitching).to receive(:active?).and_return feature_switch_active

      post :create
    end

    it 'creates a new application' do
      expect(application).to have_received(:save)
    end

    it 'redirects to the personal information page for that application' do
      expect(response).to redirect_to(application_personal_informations_path(application))
    end

    context 'feature is on' do
      let(:feature_switch_active) { true }

      it 'redirects to fee status' do
        expect(response).to redirect_to(application_fee_status_path(application))
      end
    end
  end

end
