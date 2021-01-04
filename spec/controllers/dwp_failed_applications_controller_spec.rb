require 'rails_helper'

RSpec.describe DwpFailedApplicationsController do
  let(:office) { create :office }
  let(:user) { create :staff, office: office }

  before do
    sign_in user
  end

  describe 'GET #index' do
    before do
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
