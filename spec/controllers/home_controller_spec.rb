require 'rails_helper'

RSpec.describe HomeController, type: :controller do

  include Devise::TestHelpers

  let(:staff)   { create :staff }
  let(:manager) { create :manager }
  let(:admin)   { create :admin_user }

  describe 'GET #index' do
    context 'when the user is authenticated' do
      context 'as a user' do

        before(:each) do
          sign_in staff
          get :index
        end

        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end

        it 'renders the index view' do
          expect(response).to render_template :index
        end

        it 'assigns the search form' do
          expect(assigns(:search_form)).to be_a(Forms::Search)
        end
      end

      context 'as an admin' do
        before(:each) do
          Office.delete_all
          create_list :benefit_check, 2, user_id: manager.id
          sign_in admin
          get :index
        end
        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end
      end
    end

    context 'as a manager' do
      before(:each) do
        create_list :benefit_check, 2, user_id: manager.id
        sign_in manager
        get :index
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'renders the index view' do
        expect(response).to render_template :index
      end

      it 'assigns the search form' do
        expect(assigns(:search_form)).to be_a(Forms::Search)
      end
    end

    context 'when the user is not authenticated' do

      before(:each) do
        sign_out staff
        get :index
      end

      it 'redirects to sign in page' do
        expect(response).to redirect_to(:new_user_session)
      end
    end
  end

  describe 'POST #search' do
    let(:online_application) { build_stubbed(:online_application, :with_reference) }

    before do
      allow(OnlineApplication).to receive(:find_by!).with(reference: online_application.reference).and_return(online_application)
      allow(OnlineApplication).to receive(:find_by!).with(reference: 'wrong').and_raise(ActiveRecord::RecordNotFound)

      sign_in(user)
      post :search, search: search_params
    end

    let(:user) { staff }

    context 'when reference parameter is empty' do
      let(:search_params) { { reference: nil } }

      it 'renders the index template' do
        expect(response).to render_template(:index)
      end

      it 'assigns the search form' do
        expect(assigns(:search_form)).to be_a(Forms::Search)
      end
    end

    context 'when reference parameter is present' do
      let(:search_params) { { reference: reference } }

      context 'when no online application is found with that reference' do
        let(:reference) { 'wrong' }

        it 'renders the index template' do
          expect(response).to render_template(:index)
        end

        it 'assigns the search form' do
          expect(assigns(:search_form)).to be_a(Forms::Search)
        end
      end

      context 'when an online application is found with that reference' do
        let(:reference) { online_application.reference }

        it 'redirects to the edit page for that online application' do
          expect(response).to redirect_to(edit_online_application_path(online_application))
        end
      end
    end
  end
end
