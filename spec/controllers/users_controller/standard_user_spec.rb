require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  render_views

  let(:jurisdictions) { create_list :jurisdiction, 3 }
  let(:user)          { create :user, jurisdiction: jurisdictions[0], office: create(:office, jurisdictions: jurisdictions) }
  let(:test_user)     { create :user }

  context 'standard user' do

    before { sign_in user }

    it_behaves_like 'a user regardless of role'

    describe 'GET #index' do
      it 'raises Pundit error' do
        expect {
          bypass_rescue
          get :index
        }.to raise_error Pundit::NotAuthorizedError
      end
    end

    describe 'GET #show' do
      context "when viewing somebody elses's profile" do
        it 'raises Pundit error' do
          expect {
            bypass_rescue
            get :show, id: test_user.to_param
          }.to raise_error Pundit::NotAuthorizedError
        end
      end

      context 'when viewing their own profile' do
        it 'shows them their profile' do
          get :show, id: user.to_param
          expect(response).to have_http_status(:success)
        end
      end
    end

    describe 'GET #edit' do
      context "when trying to edit somebody else's profile" do
        it 'raises Pundit error' do
          expect {
            bypass_rescue
            get :edit, id: test_user.to_param
          }.to raise_error Pundit::NotAuthorizedError
        end
      end

      context 'when trying to edit their own profile' do
        before { get :edit, id: user.to_param }

        it 'shows them their profile' do
          expect(response).to have_http_status(:success)
        end

        context 'role' do
          it 'shows them their role' do
            expect(response.body).to match user.role.to_s
          end

          it 'does not show them the options to change their role' do
            expect(response.body).not_to have_select('user[role]')
          end
        end

        it 'shows them their office' do
          expect(response.body).to match CGI.escapeHTML(user.office.name)
        end

        it 'shows them their jurisdiction' do
          expect(response.body).to match CGI.escapeHTML(user.jurisdiction.name)
        end
      end
    end

    describe 'POST #update' do

      before { sign_in user }

      context 'when trying to update their own profile' do
        new_name = 'Updated Name'
        let(:new_office) { create :office }
        let(:new_jurisdiction) { create :jurisdiction }
        before do
          params = { name: new_name, office_id: new_office.id, jurisdiction_id: new_jurisdiction.id }
          post :update, id: user.id, user: params
          user.reload
        end

        describe 'updates the user details' do
          it { expect(user.name).to eq new_name }
          it { expect(user.office).to eq new_office }
          it { expect(user.jurisdiction).to eq new_jurisdiction }
        end

        describe 'redirects back to the user show view' do
          it { expect(response.code).to eq '302' }
          it { expect(request).to redirect_to user_path }
        end
      end

      context 'when trying to escalate their own role' do
        it 'raises Pundit error' do
          expect {
            bypass_rescue
            post :update, id: user.id, user: { role: 'admin' }
          }.to raise_error Pundit::NotAuthorizedError
        end
      end

      context "when trying to edit somebody else's profile" do
        it 'raises Pundit error' do
          expect {
            bypass_rescue
            post :update, id: test_user.id, user: { name: 'random value' }
          }.to raise_error Pundit::NotAuthorizedError
        end
      end
    end
  end
end
