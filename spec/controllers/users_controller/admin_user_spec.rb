require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  render_views

  include Devise::TestHelpers

  let(:user)        { create :user }
  let(:admin_user)  { create :admin_user }
  let(:test_user)   { create :user }

  context 'admin user' do
    before do
      User.delete_all
      create_list :user, 3, office: admin_user.office
      create_list :user, 3, office: create(:office)
    end

    before(:each) { sign_in admin_user }

    describe 'GET #index' do
      it 'shows user list' do
        get :index
        expect(assigns(:users).count).to eql(7)
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
      end

      context 'for a user not in their office' do

        before(:each) { get :show, id: User.last.to_param }

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
        get :show,  id: test_user.to_param
        expect(assigns(:user)).to eq(test_user)
      end
    end

    describe 'GET #edit' do
      it 'shows edit page' do
        get :edit, id: test_user.to_param
        expect(assigns(:user)).to eq(test_user)
      end

      context 'role' do
        before(:each) do
          sign_in admin_user
          get :edit, id: admin_user.to_param
        end

        it 'shows them their role' do
          expect(response.body).to match "#{admin_user.role}"
        end

        it 'does not show them the options to change their role' do
          expect(response.body).to have_select('user[role]', options: ['User', 'Manager', 'Admin'])
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
            office_id: test_user.office_id
          }
        }

        before(:each) { put :update, id: test_user.to_param, user: new_attributes }

        it 'updates the requested user' do
          test_user.reload
          expect(test_user.role).to eql 'user'
        end

        it "does't update the requested user's email" do
          test_user.reload
          expect(test_user.email).not_to eql new_attributes[:email]
        end

        it 'assigns the requested user as @user' do
          expect(assigns(:user)).to eq(test_user)
        end

        it 'redirects to the user' do
          expect(response).to redirect_to(user_path)
        end
      end

      context 'with invalid params' do

        before(:each) { put :update, id: test_user.to_param, user: attributes_for(:invalid_user) }

        it 'assigns the user as @user' do
          expect(assigns(:user)).to eq(test_user)
        end

        it 're-renders the "edit" template' do
          expect(response).to render_template('edit')
        end
      end
    end
  end
end
