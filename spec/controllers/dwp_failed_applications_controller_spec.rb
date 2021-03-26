require 'rails_helper'

RSpec.describe DwpFailedApplicationsController do
  let(:office) { create :office }
  let(:user) { create :staff, office: office }
  let(:dwp_state) { DwpWarning::STATES[:online] }

  before do
    sign_in user
  end

  describe 'GET #index' do
    before do
      allow(controller).to receive(:dwp_checker_state).and_return dwp_state
      allow(LoadApplications).to receive(:load_users_last_dwp_failed_applications).with(user).and_return ['waiting apps']
      get :index
    end

    it 'returns the correct status code' do
      expect(response).to have_http_status(200)
    end

    it 'renders the correct template' do
      expect(response).to render_template(:index)
    end

    describe 'assigns the view models' do
      it 'loads waiting_for_part_payment application for current user' do
        expect(assigns(:list)).to eql(['waiting apps'])
      end
    end

    context 'is ready_to_process' do
      let(:dwp_state) { DwpWarning::STATES[:warning] }
      it { expect(assigns(:ready_to_process)).to be(true) }
    end

    context 'is not ready_to_process' do
      let(:dwp_state) { DwpWarning::STATES[:offline] }
      it { expect(assigns(:ready_to_process)).to be(false) }
    end

    describe 'authorize' do
      context 'admin' do
        let(:user) { create :staff, office: office, role: 'admin' }

        it 'does not redirect' do
          expect(response).to have_http_status(200)
        end
      end
      context 'mi' do
        let(:user) { create :staff, office: office, role: 'mi' }

        it 'redirect request' do
          expect(response).to have_http_status(302)
        end
      end
    end
  end
end
