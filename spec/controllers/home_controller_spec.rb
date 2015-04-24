require 'rails_helper'

RSpec.describe HomeController, type: :controller do

  include Devise::TestHelpers

  describe "GET #index" do
    let(:user)          { FactoryGirl.create :user }

    context 'when the user is authenticated' do
      before { sign_in user }
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    context 'when the user is not authenticated' do
      before { sign_out user }

      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end

end
