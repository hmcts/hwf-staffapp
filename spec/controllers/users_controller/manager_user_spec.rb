require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  render_views

  let(:manager)           { create :manager }
  let(:user_on_my_team)   { create :user, office: manager.office }
  let(:user_not_my_team)  { create :user }

  context 'manager' do

    before do
      User.delete_all
      Office.delete_all
      Jurisdiction.delete_all
      create_list :user, 2, office: manager.office
      create_list :user, 2, office: create(:office)
      sign_in manager
    end

    it_behaves_like 'a user regardless of role'

    describe 'GET #index' do
      describe 'only shows users from the current_users office' do
        before { get :index }

        it { expect(assigns(:users).count).to eq 3 }
        it { expect(User.count).to eq 5 }
      end

      describe 'does not show admins assigned to their office' do
        before do
          create :admin_user, office: manager.office
          get :index
        end

        it { expect(User.count).to eq 6 }
        it { expect(assigns(:users).count).to eq 3 }
      end
    end

    describe 'GET #show' do
      context 'for a user in their office' do

        before { get :show, id: user_on_my_team.to_param }

        it 'renders the view' do
          expect(response).to render_template :show
        end

        it 'returns a success code' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'for a user not in their office' do
        it 'returns a pundit error' do
          expect {
            bypass_rescue
            get :show, id: user_not_my_team.to_param
          }.to raise_error Pundit::NotAuthorizedError
        end
      end
    end

    describe 'GET #edit' do
      context 'role' do
        before do
          sign_in manager
          get :edit, id: manager.to_param
        end

        it 'shows them their role' do
          expect(response.body).to match 'Manager'
        end
      end

      context 'for a user not in their office' do
        it 'returns a pundit error' do
          expect {
            bypass_rescue
            get :edit, id: User.last.to_param
          }.to raise_error Pundit::NotAuthorizedError
        end
      end

      context 'for a user in their office' do
        it 'shows edit page' do
          get :edit, id: User.first.to_param
          expect(response).to render_template :edit
        end
      end
    end

    describe 'GET #deleted' do
      it 'raises a CanCan error' do
        expect {
          bypass_rescue
          get :deleted
        }.to raise_error Pundit::NotAuthorizedError
      end

    end
    describe 'PUT #update' do

      context 'role escalation' do
        context 'when trying to escalate their own role' do
          it 'raises Pundit error' do
            expect {
              bypass_rescue
              post :update, id: manager.id, user: { role: 'admin' }
            }.to raise_error Pundit::NotAuthorizedError
          end
        end

        context "when trying to escalate their office's user role" do
          context 'to manager' do
            before do
              post :update, id: user_on_my_team.id, user: { role: 'manager' }
              user_on_my_team.reload
            end

            it 'does escalate their role' do
              expect(user_on_my_team.role).to eq 'manager'
            end
          end

          context 'to admin' do
            it 'raises Pundit error' do
              expect {
                bypass_rescue
                post :update, id: user_on_my_team.id, user: { role: 'admin' }
              }.to raise_error Pundit::NotAuthorizedError
            end
          end
        end

        context 'when trying to escalates a role of a user that is not their own' do
          it 'raises Pundit error' do
            expect {
              bypass_rescue
              post :update, id: user_not_my_team.id, user: { role: 'manager' }
            }.to raise_error Pundit::NotAuthorizedError
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

        before { put :update, id: user_on_my_team.to_param, user: new_attributes }

        it "doesn't update the user's email" do
          assigns(:user)
          expect(user_on_my_team.email).not_to eq new_attributes[:email]
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

          before do
            put :update, id: user_on_my_team.to_param, user: { office_id: new_office.id, role: role }
          end

          describe 'updates the user' do
            before { user_on_my_team.reload }

            it { expect(user_on_my_team.office_id).to eq new_office.id }
            it { expect(user_on_my_team.role).to eq role }
          end

          it 'returns a redirect status' do
            expect(response).to have_http_status(:redirect)
          end

          it 'redirects to the user list' do
            expect(response).to redirect_to users_path
          end

          it 'displays an alert containing contact details for the new manager' do
            expect(flash[:notice]).to be_present
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
