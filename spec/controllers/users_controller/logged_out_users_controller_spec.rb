require 'rails_helper'

RSpec.describe UsersController do
  let(:test_user) { create(:user) }

  context 'logged out user' do
    describe 'GET #index' do
      it 'redirects to login page' do
        get :index
        expect(response).to redirect_to(user_session_path)
      end
    end

    describe 'GET #show' do
      it 'redirects to login page' do
        get :show, params: { id: test_user.to_param }
        expect(response).to redirect_to(user_session_path)
      end
    end

    describe 'GET #edit' do
      it 'redirects to login page' do
        get :edit, params: { id: test_user.to_param }
        expect(response).to redirect_to(user_session_path)
      end
    end
  end
end
