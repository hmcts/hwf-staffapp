require 'rails_helper'

RSpec.describe GuideController, type: :controller do

  include Devise::TestHelpers

  describe 'as a signed out user' do

    before(:each) do
      get :index
    end

    it 'returns a direct status' do
      expect(response).to have_http_status(302)
    end
    it 'redirects to login page' do
      expect(response).to redirect_to(user_session_path)
    end
  end

  describe 'as a signed in user' do
    let(:user)    { FactoryGirl.create :user }
    before(:each) do
      sign_in user
    end

    describe 'GET #index' do
      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end
end
