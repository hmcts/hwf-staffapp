require 'rails_helper'

RSpec.describe Users::InvitationsController, type: :controller do

  include Devise::TestHelpers

  # This should return the minimal set of attributes required to create a valid
  # user. As you add validations to user, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
        email: 'test@example.com',
        password: 'aabbccdd',
        role: 'user'
    }
  }

  let(:invalid_attributes) {
    let(:invalid_attributes) {
      {
          email: nil,
          password: 'short',
          role: 'student'
      }
    }
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # UsersController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  let(:user)          { FactoryGirl.create :user }
  let(:admin_user)    { FactoryGirl.create :admin_user }

  context 'logged in user' do
    before(:each) { sign_in user }

    describe 'GET #new' do
      xit 'generates access denied error' do
        user = User.create! valid_attributes
        expect {
          get :new, {email: user.to_param}, valid_session
        }.to raise_error CanCan::AccessDenied, 'You are not authorized to access this page.'
      end
    end
  end
end
