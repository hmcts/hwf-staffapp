require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  render_views

  include Devise::TestHelpers

  let(:user)        { create :user }
  let(:admin_user)  { create :admin_user }
  let(:manager)     { create :manager }

  context 'manager' do

    before(:each) do
      User.delete_all
      create_list :user, 3, office: manager.office
      create_list :user, 3, office: create(:office)
      sign_in manager
    end

    describe 'GET #index' do
      it 'only shows users from the current_users office' do
        get :index
        expect(assigns(:users).count).to eql(4)
        expect(User.count).to eql(7)
      end

      it 'does not show admins assigned to their office' do
        create :admin_user, office: manager.office
        get :index
        expect(User.count).to eql(8)
        expect(assigns(:users).count).to eql(4)
      end
    end

    describe 'GET #show' do
      context 'for a user in their office' do

        before(:each) { get :show, id: User.first.to_param }

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
            get :show, id: User.last.to_param
          }.to raise_error CanCan::AccessDenied, 'You are not authorized to manage this user.'
        end

        it 'renders the index view' do
          expect {
            get :show, id: User.last.to_param
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

        it 'does not show them the options to change their role' do
          expect(response.body).to have_select('user[role]', options: ['User', 'Manager'])
        end
      end

      context 'for a user not in their office' do
        it 'returns a redirect code' do
          expect {
            get :show, id: User.last.to_param
          }.to raise_error CanCan::AccessDenied, 'You are not authorized to manage this user.'
        end

        it 'renders the index view' do
          expect {
            get :show, id: User.last.to_param
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
      context 'with valid params and a new email' do
        let(:new_attributes) {
          {
            email: 'new_attributes@hmcts.gsi.gov.uk',
            role: 'user',
            office_id: manager.office_id
          }
        }

        before(:each) { put :update, id: User.first.to_param, user: new_attributes }

        it "doesn't update the user's email" do
          assigns(:user)
          expect(User.first.email).to_not eq new_attributes[:email]
        end

        it 'assigns the requested user as @user' do
          expect(assigns(:user)).to eq(User.first)
        end

        it 'redirects to the user' do
          assigns(:user)
          expect(response).to redirect_to(user_path)
        end

        context 'and changing office' do

          let(:new_office) { create(:office) }
          let(:new_office_attributes) {
            {
              email: 'new_attributes@hmcts.gsi.gov.uk',
              password: 'aabbccdd',
              role: 'user',
              office_id: new_office.id
            }
          }

          before(:each) { put :update, id: User.first.to_param, user: new_office_attributes }

          it 'updates the user' do
            user.reload
          end

          it 'returns a redirect status' do
            expect(response).to have_http_status(:redirect)
          end

          it 'redirects to the user list' do
            expect(response).to redirect_to user_path
          end

          it 'displays an alert containing contact details for the new manager' do
            err_msg = I18n.t('error_messages.user.moved_offices', user: User.first.name, office: new_office.name, contact: new_office.managers_email)
            expect(flash[:notice]).to be_present
            expect(flash[:notice]).to eql(err_msg)
          end
        end
      end

      context 'with invalid params' do
        it 'assigns the user as @user' do
          put :update, id: User.first.to_param, user: attributes_for(:invalid_user)
          expect(assigns(:user)).to eq(User.first)
        end

        it 're-renders the "edit" template' do
          put :update, id: User.first.to_param, user: attributes_for(:invalid_user)
          expect(response).to render_template('edit')
        end
      end
    end
  end
end
