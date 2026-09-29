require 'rails_helper'

RSpec.describe Users::SessionsController do
  describe 'GET #new' do
    let(:dwp_monitor) { instance_double(DwpMonitor, state: 'warning') }
    let(:hmrc_monitor) { instance_double(HmrcMonitor, state: 'offline') }

    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      allow(DwpMonitor).to receive(:new).and_return(dwp_monitor)
      allow(HmrcMonitor).to receive(:new).and_return(hmrc_monitor)
      get :new
    end

    it 'renders the sign in page' do
      expect(response).to have_http_status(:ok)
    end

    it 'loads the DWP checker state for the banner' do
      expect(assigns(:dwp_state)).to eq('warning')
    end

    it 'loads the HMRC checker state for the banner' do
      expect(assigns(:hmrc_state)).to eq('offline')
    end
  end
end
