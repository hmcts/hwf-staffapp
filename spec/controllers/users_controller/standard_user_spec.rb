require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  include Devise::TestHelpers

  let(:user)        { create :user }
  let(:test_user)   { create :user }

  context 'standard user' do

    before(:each) { sign_in user }

    describe 'GET #index' do
      it 'generates access denied error' do
        expect {
          get :index
        }.to raise_error CanCan::AccessDenied, 'You are not authorized to access this page.'
      end
    end

    describe 'GET #show' do
      context "when viewing somebody elses's profile" do
        it 'redirects to the home page' do
          get :show, id: test_user.to_param
          expect(response).to redirect_to(root_path)
        end
      end

      context 'when viewing their own profile' do
        it 'shows them their profile' do
          get :show, id: user.to_param
          expect(response).to have_http_status(:success)
        end
      end
    end

    describe 'GET #edit' do
      context "when trying to edit somebody else's profile" do
        it 'redirects to the home page' do
          get :edit, id: test_user.to_param
          expect(response).to redirect_to(root_path)
        end
      end

      context 'when trying to edit their own profile' do
        it 'shows them their profile' do
          get :edit, id: user.to_param
          expect(response).to have_http_status(:success)
        end
      end
    end

    describe 'POST #update' do

      before(:each) { sign_in user }

      context 'when trying to update their own profile' do
        new_name = 'Updated Name'
        before(:each) { post :update, id: user.id, user: { name: new_name } }

        it 'updates the user details' do
          user.reload
          expect(user.name).to eq new_name
        end

        it 'redirects back to the user show view' do
          expect(response.code).to eq '302'
          expect(request).to redirect_to user_path
        end
      end

      context "when trying to edit somebody else's profile" do
        it "doesn't allow editing of the user details" do
          post :update, id: test_user.id, user: { name: 'random value' }
          expect redirect_to user_path(user.id)
        end
      end
    end
  end
end
