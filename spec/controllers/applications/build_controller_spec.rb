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
        expect(response).to redirect_to(application_personal_information_path(assigns(:application)))
      end
    end

    describe 'PUT' do
      let(:applicant) { create :applicant_with_all_details }
      let(:application) { create :application, user_id: user.id, applicant: applicant }

      describe 'personal_information' do
        before { put :update, application_id: application.id, id: :personal_information, application: { last_name: 'asd' } }

        it 'renders 400 error' do
          expect(response).to have_http_status(400)
        end
      end

      describe 'application_details' do
        before { put :update, application_id: application.id, id: :application_details, application: { fee: 300 } }

        it 'renders 400 error' do
          expect(response).to have_http_status(400)
        end
      end

      describe 'benefits' do
        before { put :update, application_id: application.id, id: :benefits, application: { benefits: false } }

        it 'renders 400 error' do
          expect(response).to have_http_status(400)
        end
      end
    end

    describe 'GET ' do
      let(:applicant) { create :applicant_with_all_details }
      let(:detail) { create :complete_detail }
      let(:application) { create :application, user_id: user.id, applicant: applicant, detail: detail }

      context 'personal_information' do
        before { get :show, application_id: application.id, id: :personal_information }

        it 'redirects to the new process controller' do
          expect(response).to redirect_to(application_personal_information_path(application))
        end
      end

      context 'application_details' do
        before { get :show, application_id: application.id, id: :application_details }

        it 'redirects to the new process controller' do
          expect(response).to redirect_to(application_application_details_path(application))
        end
      end

      context 'savings_investments' do
        before { get :show, application_id: application.id, id: :savings_investments }

        it 'displays the savings and investments view' do
          expect(response).to render_template :savings_investments
        end
      end

      describe 'benefits' do
        before { get :show, application_id: application.id, id: :benefits }

        it 'redirects to the new process controller' do
          expect(response).to redirect_to(application_benefits_path(application))
        end
      end

      describe 'benefits_result' do
        before { get :show, application_id: application.id, id: :benefits_result }

        it 'redirects to the new process controller' do
          expect(response).to redirect_to(application_benefits_result_path(application))
        end
      end

      context 'income' do
        context 'user has selected "no" to benefits' do
          before do
            application = create(:application, :no_benefits, dependents: false)
            get :show, application_id: application.id, id: :income
          end

          it 'displays the income view' do
            expect(response).to render_template :income
          end

        end

        context 'user has selected "yes" to benefits' do
          before do
            application.benefits = true
            application.save
            get :show, application_id: application.id, id: :income
          end

          it 'redirects' do
            expect(response).to have_http_status(:redirect)
          end

          it 'redirects to the summary page' do
            expect(response).to redirect_to(application_build_path(application_id: assigns(:application).id, id: :summary))
          end
        end
      end
    end
  end
end
