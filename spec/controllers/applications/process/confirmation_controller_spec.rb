require 'rails_helper'

RSpec.describe Applications::Process::ConfirmationController, type: :controller do
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

  context 'GET #index' do
    before { get :index, params: { application_id: application.id }}

    it 'displays the confirmation view' do
      expect(response).to render_template :index
    end

    it 'assigns application' do
      expect(assigns(:application)).to eql(application)
    end

    it 'assigns confirm' do
      expect(assigns(:confirm)).to be_a_kind_of(Views::Confirmation::Result)
    end
  end

end
