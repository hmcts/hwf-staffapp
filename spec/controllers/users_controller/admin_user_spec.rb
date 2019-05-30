require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  render_views

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
      sign_in admin_user
    end

    it_behaves_like 'a user regardless of role'

    describe 'GET #index' do

      before { get :index }

      it 'shows user list' do
        expect(assigns(:users).count).to eq 7
      end

      context 'when one user is deleted' do
        before { user_on_admins_team.destroy }
        it "doesn't show that user" do
          expect(response.body).not_to match user_on_admins_team.name
        end
      end
    end

    describe 'GET #show' do
      context 'for a user in their office' do

        before do
          get :show, id: user_on_admins_team.to_param
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

      context 'for themselves' do
        before { get :show, id: admin_user }
        it 'does not have a delete user link' do
          expect(response.body).not_to have_content 'Remove staff member'
        end
      end

      context 'for a user not in their office' do

        before { get :show, id: user_not_on_admins_team.to_param }

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
        get :show, id: user_not_on_admins_team.to_param
        expect(assigns(:user)).to eq(user_not_on_admins_team)
      end
    end

    describe 'GET #edit' do
      it 'shows edit page' do
        get :edit, id: user_not_on_admins_team.to_param
        expect(assigns(:user)).to eq(user_not_on_admins_team)
      end

      context 'role' do
        before do
          sign_in admin_user
          get :edit, id: admin_user.to_param
        end

        it 'shows them their role' do
          expect(response.body).to match admin_user.role.to_s
        end

        describe 'shows them all options to change their role' do
          it { expect(response.body).to have_xpath('//input[@name="user[role]" and @value="mi"]') }
          it { expect(response.body).to have_xpath('//input[@name="user[role]" and @value="admin"]') }
          it { expect(response.body).to have_xpath('//input[@name="user[role]" and @value="manager"]') }
          it { expect(response.body).to have_xpath('//input[@name="user[role]" and @value="user"]') }
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

        before { put :update, id: user_not_on_admins_team.to_param, user: new_attributes }

        it 'updates the requested user' do
          user_not_on_admins_team.reload
          expect(user_not_on_admins_team.role).to eql 'user'
        end

        it "update user's email via cornfirmable" do
          user_not_on_admins_team.reload
          expect(user_not_on_admins_team.unconfirmed_email).to eql new_attributes[:email]
        end

        it 'assigns the requested user as @user' do
          expect(assigns(:user)).to eq(user_not_on_admins_team)
        end

        it 'redirects to the user' do
          expect(response).to redirect_to(user_path)
        end
      end

      context 'with invalid params' do

        before { put :update, id: user_not_on_admins_team.to_param, user: attributes_for(:invalid_user) }

        it 'assigns the user as @user' do
          expect(assigns(:user)).to eq(user_not_on_admins_team)
        end

        it 're-renders the "edit" template' do
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'GET #deleted' do
      before { get :deleted }

      it 'returns a success code' do
        expect(response).to have_http_status(:success)
      end

      it 'renders the index view' do
        expect(response).to render_template :deleted
      end
    end

    describe 'PATCH #restore' do
      let(:deleted_user) { create :user, deleted_at: Time.zone.now }

      before do
        patch :restore, id: deleted_user.to_param
      end

      it 'returns a redirect code' do
        expect(response).to have_http_status(:redirect)
      end
    end

    describe 'DELETE #destroy' do
      context 'when deleting themselves' do
        it 'raises Pundit error' do
          expect {
            bypass_rescue
            delete :destroy, id: admin_user.to_param
          }.to raise_error Pundit::NotAuthorizedError
        end
      end

      context 'deleting another user' do
        before { get :destroy, id: user_on_admins_team.to_param }
        it 'redirects to the user index' do
          expect(response).to redirect_to(users_path)
        end
      end
    end

    describe 'PATCH #invite' do

      before { patch :invite, id: user_not_on_admins_team.to_param }

      it 'returns a redirect code' do
        expect(response).to have_http_status(:redirect)
      end

      it 'returns a confirmation message' do
        expect(flash[:notice]).to eq("An invitation was sent to #{user_not_on_admins_team.name}")
      end
    end
  end
end
