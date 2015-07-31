require 'rails_helper'

RSpec.describe Applications::BuildController, type: :controller do
  render_views

  include Devise::TestHelpers

  let(:user)          { create :user }

  context 'as a logged in user' do
    before { sign_in user }

    describe 'GET applications/build#create' do
      before { get :create }

      it 'redirect to the personal_information view' do
        expect(response).to redirect_to(application_build_path(application_id: assigns(:application).id, id: :personal_information))
      end
    end

    describe 'GET ' do

      let(:application) { create :application }

      context 'personal_information' do
        before { get :show, application_id: application.id, id: :personal_information }

        it 'displays the personal information view' do
          expect(response).to render_template :personal_information
        end
      end

      context 'application_details' do
        before { get :show, application_id: application.id, id: :application_details }

        it 'displays the application details view' do
          expect(response).to render_template :application_details
        end
      end

      context 'savings_investments' do
        before { get :show, application_id: application.id, id: :savings_investments }

        it 'displays the savings and investments view' do
          expect(response).to render_template :savings_investments
        end
      end

      context 'benefits' do
        before { get :show, application_id: application.id, id: :benefits }

        it 'displays the benefits view' do
          expect(response).to render_template :benefits
        end
      end

      context 'income' do
        before { get :show, application_id: application.id, id: :income }

        it 'displays the income view' do
          expect(response).to render_template :income
        end
      end

      context 'summary' do
        before { get :show, application_id: application.id, id: :summary }

        it 'displays the summary view' do
          expect(response).to render_template :summary
        end
      end
    end
  end
end
