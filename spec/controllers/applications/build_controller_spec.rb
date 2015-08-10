require 'rails_helper'

RSpec.describe Applications::BuildController, type: :controller do
  render_views

  include Devise::TestHelpers
  before { WebMock.disable_net_connect!(allow: 'codeclimate.com') }

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

      let(:application) { create :application, user_id: user.id }

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
        context 'user has selected "no" to benefits' do
          before do
            application.benefits = false
            application.save
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
            expect(response).to redirect_to redirect_to(application_build_path(application_id: assigns(:application).id, id: :summary))
          end
        end
      end

      context 'benefits result' do
        context 'user has selected "yes" to benefits' do
          before do
            stub_request(:post, "#{ENV['DWP_API_PROXY']}/api/benefit_checks").with(body:
            {
              birth_date: (Time.zone.today - 20.years).strftime('%Y%m%d'),
              entitlement_check_date: (Time.zone.today).strftime('%Y%m%d'),
              id: "#{user.name.gsub(' ', '').downcase.truncate(27)}@#{application.created_at.strftime('%y%m%d%H%M%S')}.#{application.id}",
              ni_number: 'AB123456A',
              surname: application.last_name.upcase
            }).to_return(status: 200, body: '', headers: {})
            application.benefits = true
            application.ni_number = 'AB123456A'
            application.save
            get :show, application_id: application.id, id: :benefits_result
          end

          it 'displays the benefits result view' do
            expect(response).to render_template :benefits_result
          end
        end

        context 'user has selected "no" to benefits' do
          before do
            application.benefits = false
            application.save
            get :show, application_id: application.id, id: :benefits_result
          end

          it 'redirects' do
            expect(response).to have_http_status(:redirect)
          end

          it 'redirects to the income page' do
            expect(response).to redirect_to redirect_to(application_build_path(application_id: assigns(:application).id, id: :income))
          end
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
