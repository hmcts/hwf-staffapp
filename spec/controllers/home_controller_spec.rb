require 'rails_helper'

RSpec.describe HomeController, type: :controller do

  include Devise::TestHelpers

  describe 'GET #dashboard' do
    let(:user)      { create :user }
    let(:manager)   { create :manager }
    let(:admin)     { create :admin_user }

    context 'when the user is authenticated' do
      context 'as a user' do

        before(:each) do
          sign_in user
          get :dashboard
        end

        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end

        it 'renders the dashboard view' do
          expect(response).to render_template :dashboard
        end
      end

      context 'as an admin' do
        before(:each) do
          DwpCheck.delete_all
          Office.delete_all
          FactoryGirl.create_list :dwp_check, 2, created_by: manager, office: manager.office
          sign_in admin
          get :dashboard
        end

        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end

        it 'populates a list of report_data' do
          expect(assigns(:report_data).count).to eql(2)
        end
      end
    end

    context 'as a manager' do

      before(:each) do
        DwpCheck.delete_all
        create_list :dwp_check, 2, created_by: manager, office: manager.office
        sign_in manager
        get :dashboard
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'populates a list of dwp_checks' do
        expect(assigns(:dwpchecks).count).to eql(2)
      end

      it 'renders the dashboard view' do
        expect(response).to render_template :dashboard
      end
    end

    context 'when the user is not authenticated' do

      before(:each) do
        sign_out user
        get :dashboard
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'renders the dashboard view' do
        expect(response).to render_template :dashboard
      end
    end
  end
end
