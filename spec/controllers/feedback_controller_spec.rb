require 'rails_helper'

RSpec.describe FeedbackController, type: :controller do

  include Devise::TestHelpers

  let(:user)          { FactoryGirl.create :user, office: FactoryGirl.create(:office) }
  let(:good_feedback) {
    {
      experience: 'aaa',
      ideas: 'bbb',
      rating: '5',
      help: '1' }
  }
  context 'as a signed in user' do

    before(:each) { sign_in user }
    let(:feedback) { FactoryGirl.build(:feedback, ideas: 'None') }

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
