require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  render_views

  include Devise::TestHelpers

  let(:manager)           { create :manager }
  let(:user_on_my_team)   { create :user, office: manager.office }
  let(:user_not_my_team)  { create :user }

  context 'manager' do

    before(:each) do
      User.delete_all
      Office.delete_all
      Jurisdiction.delete_all
      create_list :user, 2, office: manager.office
      create_list :user, 2, office: create(:office)
      sign_in manager
    end

    it_behaves_like 'a user regardless of role'

    describe 'GET #index' do
      it 'only shows users from the current_users office' do
        get :index
        expect(assigns(:users).count).to eql(3)
        expect(User.count).to eql(5)
      end

      it 'does not show admins assigned to their office' do
        create :admin_user, office: manager.office
        get :index
        expect(User.count).to eql(6)
        expect(assigns(:users).count).to eql(3)
      end
    end

    describe 'GET #show' do
      context 'for a user in their office' do

        before(:each) { get :show, id: user_on_my_team.to_param }

        it 'renders the view' do
          expect(response).to render_template :show
        end

        it 'returns a success code' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'for a user not in their office' do
        it 'returns a redirect code' do
          expect {
            get :show, id: user_not_my_team.to_param
          }.to raise_error CanCan::AccessDenied, 'You are not authorized to manage this user.'
        end

        it 'renders the index view' do
          expect {
            get :show, id: user_not_my_team.to_param
          }.to raise_error CanCan::AccessDenied, 'You are not authorized to manage this user.'
        end
      end
    end

    describe 'GET #edit' do
      context 'role' do
        before(:each) do
          sign_in manager
          get :edit, id: manager.to_param
        end

        it 'shows them their role' do
          expect(response.body).to match "#{manager.role}"
        end
      end

      context 'for a user not in their office' do
        it 'returns a redirect code' do
          expect {
            get :edit, id: User.last.to_param
          }.to raise_error CanCan::AccessDenied, 'You are not authorized to manage this user.'
        end

        it 'renders the index view' do
          expect {
            get :edit, id: User.last.to_param
          }.to raise_error CanCan::AccessDenied, 'You are not authorized to manage this user.'
        end
      end

      context 'for a user in their office' do
        it 'shows edit page' do
          get :edit, id: User.first.to_param
          expect(response).to render_template :edit
        end
      end
    end

    describe 'PUT #update' do

      context 'role escalation' do
        context 'when trying to escalate their own role' do
          before do
            post :update, id: manager.id, user: { role: 'admin' }
            manager.reload
          end

          it "doesn't escalates their role" do
            expect(manager.role).not_to eq 'admin'
          end
        end

        context "when trying to escalate their user's role" do
          context 'to manager' do
            before do
              post :update, id: user_on_my_team.id, user: { role: 'manager' }
              user_on_my_team.reload
            end

            it 'does escalates their role' do
              expect(user_on_my_team.role).to eq 'manager'
            end
          end

          context 'to admin' do
            before do
              post :update, id: user_on_my_team.id, user: { role: 'admin' }
              user_on_my_team.reload
            end

            it "doesn't escalates their role" do
              expect(user_on_my_team.role).to eq 'user'
            end
          end
        end

        context 'when trying to escalates a role of a user that is not their own' do
          it "doesn't escalates their role" do
            expect {
              post :update, id: user_not_my_team.id, user: { role: 'manager' }
            }.to raise_error CanCan::AccessDenied, 'You are not authorized to manage this user.'
          end
        end
      end

      context 'with valid params and a new email' do
        let(:new_attributes) {
          {
            email: 'new_attributes@hmcts.gsi.gov.uk',
            role: 'user',
            office_id: manager.office_id
          }
        }

        before(:each) { put :update, id: user_on_my_team.to_param, user: new_attributes }

        it "doesn't update the user's email" do
          assigns(:user)
          expect(user_on_my_team.email).to_not eq new_attributes[:email]
        end

        it 'assigns the requested user as @user' do
          expect(assigns(:user)).to eq(user_on_my_team)
        end

        it 'redirects to the user' do
          assigns(:user)
          expect(response).to redirect_to(user_path)
        end

        context 'and changing office and role' do
          let(:new_office) { create(:office) }
          let(:role) { 'user' }

          before(:each) do
            put :update, id: user_on_my_team.to_param, user: { office_id: new_office.id, role: role }
          end

          it 'updates the user' do
            user_on_my_team.reload
            expect(user_on_my_team.office_id).to eq new_office.id
            expect(user_on_my_team.role).to eq role
          end

          it 'returns a redirect status' do
            expect(response).to have_http_status(:redirect)
          end

          it 'redirects to the user list' do
            expect(response).to redirect_to users_path
          end

          it 'displays an alert containing contact details for the new manager' do
            err_msg = I18n.t('error_messages.user.moved_offices', user: user_on_my_team.name, office: new_office.name, contact: new_office.managers_email)
            expect(flash[:notice]).to be_present
            expect(flash[:notice]).to eql(err_msg)
          end
        end
      end

      context 'with invalid params' do

        before { put :update, id: user_on_my_team.to_param, user: attributes_for(:invalid_user) }

        it 'assigns the user as @user' do
          expect(assigns(:user)).to eq(user_on_my_team)
        end

        it 're-renders the "edit" template' do
          expect(response).to render_template('edit')
        end
      end
    end
  end
end
