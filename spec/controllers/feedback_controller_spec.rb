require 'rails_helper'

RSpec.describe FeedbackController, type: :controller do
  let(:office) { create(:office) }
  let(:user)          { create :user, office: office }
  let(:admin)         { create :admin_user, office: office }

  context 'as a signed out user' do
    describe 'GET #new' do
      before(:each) { get :new }
      it 'returns http redirect' do
        expect(response).to have_http_status(:redirect)
      end

      it 'redirects to the sign in page' do
        expect(response).to redirect_to(user_session_path)
      end
    end

    describe 'GET #index' do
      before(:each) { get :index }
      it 'returns http redirect' do
        expect(response).to have_http_status(:redirect)
      end

      it 'redirects to the sign in page' do
        expect(response).to redirect_to(user_session_path)
      end
    end
  end

  context 'as a signed in user' do
    before(:each) { sign_in user }

    describe 'GET #index' do
      it 'raises Pundit error' do
        expect {
          bypass_rescue
          get :index
        }.to raise_error Pundit::NotAuthorizedError
      end
    end

    describe 'GET #new' do
      before(:each) { get :new }
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'renders the correct template' do
        expect(response).to render_template(:new)
      end
    end

    describe 'POST #create' do
      let(:feedback_attributes) { attributes_for(:feedback, user: user, office: office) }

      it 'returns http success' do
        post :create, feedback: feedback_attributes
        expect(response).to redirect_to(root_path)
      end

      it 'creates a new feedback entry' do
        expect {
          post :create, feedback: feedback_attributes
        }.to change(Feedback, :count).by(1)
      end
    end
  end

  context 'as a signed in admin' do
    before(:each) { sign_in admin }
    let(:feedback) { build(:feedback, ideas: 'None') }

    describe 'GET #index' do
      before(:each) { get :index }
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'renders the correct template' do
        expect(response).to render_template(:index)
      end

      context 'when there is feedback from a deleted user' do
        let(:user) { create :deleted_user, office: create(:office) }
        before { create(:feedback, ideas: 'None', user: user, office: user.office) }

        it 'renders the correct template' do
          expect(response).to render_template(:index)
        end
      end
    end

    describe 'GET #new' do
      it 'raises Pundit error' do
        expect {
          bypass_rescue
          get :new
        }.to raise_error Pundit::NotAuthorizedError
      end

    end

    describe 'POST #create' do
      let(:feedback_attributes) { attributes_for(:feedback, user: admin, office: office) }

      it 'raises Pundit error' do
        expect {
          bypass_rescue
          post :create, feedback: feedback_attributes
        }.to raise_error Pundit::NotAuthorizedError
      end

    end
  end
end
