require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:test_user) { create :user }

  context 'logged out user' do
    describe 'GET #index' do
      it 'redirects to login page' do
        get :index
        expect(response).to redirect_to(user_session_path)
      end
    end

    describe 'GET #show' do
      it 'redirects to login page' do
        get :show, id: test_user.to_param
        expect(response).to redirect_to(user_session_path)
      end
    end

    describe 'GET #edit' do
      it 'redirects to login page' do
        get :edit, id: test_user.to_param
        expect(response).to redirect_to(user_session_path)
      end
    end
  end
end
