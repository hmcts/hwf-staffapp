require 'rails_helper'

RSpec.describe Applications::BuildController, type: :controller do
  render_views

  include Devise::TestHelpers

  let(:user)          { create :user }

  context 'as a logged in user' do
    before { sign_in user }

    describe 'GET #create' do
      before { get :create }

      it 'redirect to the personal_information view' do
        expect(response).to redirect_to(application_build_path(application_id: assigns(:application).id, id: :personal_information))
      end
    end

    describe 'GET build#show' do
      context 'personal_information' do
        it 'displays the personal information view'

      end

      context 'application_details' do
        it 'displays the application details view'

      end

      context 'savings_investments' do
        it 'displays the savings and investments view'
      end

      context 'summary' do
        it 'displays the summary view'

      end
    end
  end
end
