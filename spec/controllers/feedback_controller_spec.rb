require 'rails_helper'

RSpec.describe FeedbackController, type: :controller do

  include Devise::TestHelpers

  let(:user)          { create :user, office: create(:office) }
  let(:admin)         { create :admin_user, office: create(:office) }
  let(:good_feedback) {
    {
      experience: 'aaa',
      ideas: 'bbb',
      rating: '5',
      help: '1' }
  }

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
    let(:feedback) { build(:feedback, ideas: 'None') }

    describe 'GET #index' do
      it 'returns http redirect' do
        expect {
          get :index
        }.to raise_error CanCan::AccessDenied, 'You are not authorized to access this page.'
      end
      it 'redirects to the sign in page' do
        expect {
          get :index
        }.to raise_error CanCan::AccessDenied, 'You are not authorized to access this page.'
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
      it 'returns http success' do
        post :create, feedback: good_feedback
        expect(response).to redirect_to(root_path)
      end
      it 'creates a new feedback entry' do
        expect {
          post :create, feedback: good_feedback
        }.to change(Feedback, :count).by(1)
      end
    end
  end

  context 'as a signed in admin' do

    before(:each) { sign_in admin }
    let(:feedback) { build(:feedback, ideas: 'None') }

    describe 'GET #index' do
      before(:each) { get :index }
      it 'returns http redirect' do
        expect(response).to have_http_status(:success)
      end
      it 'redirects to the sign in page' do
        expect(response).to render_template(:index)
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
      it 'returns http success' do
        post :create, feedback: good_feedback
        expect(response).to redirect_to(root_path)
      end
      it 'creates a new feedback entry' do
        expect {
          post :create, feedback: good_feedback
        }.to change(Feedback, :count).by(1)
      end
    end
  end

end
