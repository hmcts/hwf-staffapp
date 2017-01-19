require 'rails_helper'

RSpec.describe GuideController, type: :controller do
  describe 'as a signed out user' do

    before { get :index }

    it 'returns a direct status' do
      expect(response).to have_http_status(302)
    end

    it 'redirects to login page' do
      expect(response).to redirect_to(user_session_path)
    end
  end

  describe 'as a signed in user' do

    before do
      sign_in create :user
      get :index
    end

    describe 'GET #index' do
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'renders the correct view' do
        expect(response).to render_template :index
      end
    end
  end
end
