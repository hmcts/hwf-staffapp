require 'spec_helper'

RSpec.describe CalculatorController, type: :controller do

  include Devise::TestHelpers

  context 'as a signed in user' do
    let(:user)    { FactoryGirl.create :user }
    before(:each) do
      sign_in user
      get :income
    end

    describe "GET #income" do
      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it 'renders the income calculator template' do
        expect(response).to render_template('income')
      end
    end
  end
end
