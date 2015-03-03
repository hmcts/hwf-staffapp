require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  include Devise::TestHelpers

  # This should return the minimal set of attributes required to create a valid
  # user. As you add validations to user, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
      email: 'test@example.com',
      password: 'aabbccdd',
      role: 'user'
    }
  }

  let(:invalid_attributes) {
    {
      email: nil,
      password: 'short',
      role: 'student'
    }
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # UsersController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  let(:user)          { FactoryGirl.create :user }
  let(:admin_user)    { FactoryGirl.create :admin_user }
  let(:test_user) { User.create! valid_attributes }

  context 'logged out user' do
    describe 'GET #index' do
      it 'redirects to login page' do
        get :index, {}, valid_session
        expect(response).to redirect_to(user_session_path)
      end
    end
    describe 'GET #show' do
      it 'redirects to login page' do
        get :show, { id: test_user.to_param }, valid_session
        expect(response).to redirect_to(user_session_path)
      end
    end
    describe 'GET #edit' do
      it 'redirects to login page' do
        get :edit, { id: test_user.to_param }, valid_session
        expect(response).to redirect_to(user_session_path)
      end
    end
  end

  context 'standard user' do
    before(:each) { sign_in user }
    describe 'GET #index' do
      it 'generates access denied error' do
        expect {
          get :index, {}, valid_session
        }.to raise_error CanCan::AccessDenied, 'You are not authorized to access this page.'
      end
    end
    describe 'GET #show' do
      it 'generates access denied error' do
        expect {
          get :edit, { id: test_user.to_param }, valid_session
        }.to raise_error CanCan::AccessDenied, 'You are not authorized to access this page.'
      end
    end
    describe 'GET #edit' do
      it 'generates access denied error' do
        expect {
          get :show, { id: test_user.to_param }, valid_session
        }.to raise_error CanCan::AccessDenied, 'You are not authorized to access this page.'
      end
    end
  end

  context 'admin user' do
    before(:each) { sign_in admin_user }
    describe 'GET #index' do
      it 'shows user list' do
        get :index, {}, valid_session
        test_user
        user
        expect(assigns(:users).last).to eql(user)
      end
    end
    describe 'GET #show' do
      it 'shows user details' do
        get :show, { id: test_user.to_param }, valid_session
        expect(assigns(:user)).to eq(test_user)
      end
    end
    describe 'GET #edit' do
      it 'shows edit page' do
        get :edit, { id: test_user.to_param }, valid_session
        expect(assigns(:user)).to eq(test_user)
      end
    end
    describe 'PUT #update' do
      context 'with valid params' do
        let(:new_attributes) {
          {
            email: 'new_attributes@example.com',
            password: 'aabbccdd',
            role: 'user'
          }
        }

        it 'updates the requested user' do
          put :update, { id: test_user.to_param, user: new_attributes }, valid_session
          user.reload
        end

        it 'assigns the requested user as @user' do
          put :update, { id: test_user.to_param, user: valid_attributes }, valid_session
          expect(assigns(:user)).to eq(test_user)
        end

        it 'redirects to the user' do
          put :update, { id: test_user.to_param, user: valid_attributes }, valid_session
          expect(response).to redirect_to(user_path)
        end
      end

      context 'with invalid params' do
        it 'assigns the user as @user' do
          put :update, { id: test_user.to_param, user: invalid_attributes }, valid_session
          expect(assigns(:user)).to eq(test_user)
        end

        it 're-renders the "edit" template' do
          put :update, { id: test_user.to_param, user: invalid_attributes }, valid_session
          expect(response).to render_template('edit')
        end
      end
    end
  end
end
