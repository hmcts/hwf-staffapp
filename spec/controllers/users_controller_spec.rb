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

  context 'logged out user' do
    describe 'GET #index' do
      it 'redirects to login page' do
        get :index, {}, valid_session
        expect(response).to redirect_to(user_session_path)
      end
    end
    describe 'GET #show' do
      it 'redirects to login page' do
        user = User.create! valid_attributes
        get :show, { id: user.to_param }, valid_session
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
        user = User.create! valid_attributes
        expect {
          get :show, { id: user.to_param }, valid_session
        }.to raise_error CanCan::AccessDenied, 'You are not authorized to access this page.'
      end
    end
  end

  context 'admin user' do
    before(:each) { sign_in admin_user }
    describe 'GET #index' do
      it 'shows user list' do
        user = User.create! valid_attributes
        get :index, {}, valid_session
        expect(assigns(:users).first).to eq(user)
      end
    end
    describe 'GET #show' do
      it 'shows user details' do
        user = User.create! valid_attributes
        get :show, { id: user.to_param }, valid_session
        expect(assigns(:user)).to eq(user)
      end
    end
  end
end
