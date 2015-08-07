require 'rails_helper'
require 'support/shared_examples/default_user_shared'

RSpec.describe UsersController, type: :controller do
  render_views

  include Devise::TestHelpers

  let(:admin_user)              { create :admin_user }
  let(:user_on_admins_team)     { create :user, name: 'Bob', office: admin_user.office }
  let(:user_not_on_admins_team) { create :user }

  context 'admin user' do
    before do
      User.delete_all
      Office.delete_all
      Jurisdiction.delete_all
      create_list :user, 3, office: admin_user.office
      create_list :user, 3
    end

    before(:each) { sign_in admin_user }

    it_behaves_like 'a user regardless of role'

    describe 'GET #index' do

      before(:each) { get :index }

      it 'shows user list' do
        expect(assigns(:users).count).to eql(7)
      end

      context 'when one user is deleted' do
        it "doesn't show that user" do
          user_on_admins_team.destroy
          expect(response.body).not_to match user_on_admins_team.name
        end
      end
    end

    describe 'GET #show' do
      context 'for a user in their office' do

        before(:each) do
          get :show, id: User.first.to_param
        end

        it 'renders the view' do
          expect(response).to render_template :show
        end

        it 'returns a success code' do
          expect(response).to have_http_status(:success)
        end

        it 'has delete user link' do
          expect(response.body).to have_content 'Remove staff member'
        end
      end

      context 'for a user not in their office' do

        before(:each) { get :show, id: user_not_on_admins_team.to_param }

        it 'returns a success code' do
          expect(response).to have_http_status(:success)
        end

        it 'renders the index view' do
          expect(response).to render_template :show
        end
      end
    end

    describe 'GET #show' do
      it 'shows user details' do
        get :show,  id: user_not_on_admins_team.to_param
        expect(assigns(:user)).to eq(user_not_on_admins_team)
      end
    end

    describe 'GET #edit' do
      it 'shows edit page' do
        get :edit, id: user_not_on_admins_team.to_param
        expect(assigns(:user)).to eq(user_not_on_admins_team)
      end

      context 'role' do
        before(:each) do
          sign_in admin_user
          get :edit, id: admin_user.to_param
        end

        it 'shows them their role' do
          expect(response.body).to match "#{admin_user.role}"
        end

        it 'shows them all options to change their role' do
          expect(response.body).to have_xpath('//input[@name="user[role]"]', count: 3)
          expect(response.body).to have_xpath('//input[@name="user[role]" and @value="admin"]')
          expect(response.body).to have_xpath('//input[@name="user[role]" and @value="manager"]')
          expect(response.body).to have_xpath('//input[@name="user[role]" and @value="user"]')
        end
      end
    end

    describe 'PUT #update' do
      context 'with valid params and a new email' do

        let(:new_attributes) {
          {
            email: 'new_attributes@hmcts.gsi.gov.uk',
            password: 'aabbccdd',
            role: 'user',
            office_id: user_not_on_admins_team.office_id
          }
        }

        before(:each) { put :update, id: user_not_on_admins_team.to_param, user: new_attributes }

        it 'updates the requested user' do
          user_not_on_admins_team.reload
          expect(user_not_on_admins_team.role).to eql 'user'
        end

        it "does't update the requested user's email" do
          user_not_on_admins_team.reload
          expect(user_not_on_admins_team.email).not_to eql new_attributes[:email]
        end

        it 'assigns the requested user as @user' do
          expect(assigns(:user)).to eq(user_not_on_admins_team)
        end

        it 'redirects to the user' do
          expect(response).to redirect_to(user_path)
        end
      end

      context 'with invalid params' do

        before(:each) { put :update, id: user_not_on_admins_team.to_param, user: attributes_for(:invalid_user) }

        it 'assigns the user as @user' do
          expect(assigns(:user)).to eq(user_not_on_admins_team)
        end

        it 're-renders the "edit" template' do
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'DELETE #destroy' do
      before(:each) { get :destroy, id: user_on_admins_team.to_param }

      it 'redirects to the user index' do
        expect(response).to redirect_to(users_path)
      end
    end
  end
end
