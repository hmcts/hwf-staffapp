require 'rails_helper'

RSpec.describe DwpChecksController, type: :controller do

  include Devise::TestHelpers

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # DwpChecksController. Be sure to keep this updated too.
  let(:valid_session) { {} }
  let(:invalid_attributes) {
    {
      last_name: nil
    }
  }
  let(:valid_attributes) {
    {
      id: nil,
      last_name: 'Smith',
      dob: '2000-01-01',
      ni_number: 'AB123456C',
      date_to_check: nil,
      checked_by: nil,
      laa_code: nil,
      unique_number: nil
    }
  }

  let(:user)          { FactoryGirl.create :user }
  let(:admin_user)    { FactoryGirl.create :admin_user }

  context 'logged out user' do
    describe 'GET #show' do
      it 'redirects to login page' do
        dwp_check = DwpCheck.create! valid_attributes
        get :show, {:unique_number => dwp_check.to_param}, valid_session
        expect(response).to redirect_to(user_session_path)
      end
    end
    describe 'GET #new' do
      it 'redirects to login page' do
        get :new, {}, valid_session
        expect(response).to redirect_to(user_session_path)
      end
    end
  end

  context 'logged in as standard user' do

    before(:each) { sign_in user }

    describe 'GET #show' do
      it 'should assign the requested dwp_check as @dwp_check' do
        dwp_check = DwpCheck.create! valid_attributes
        get :show, {:unique_number => dwp_check.unique_number}, valid_session
        expect(assigns(:dwp_checker)).to eq(dwp_check)
        expect(response).to render_template('dwp_checks/show')
      end
    end
    describe 'GET #new' do
      it 'should render the expected view' do
        get :new, {}, valid_session
        expect(response.status).to eql(200)
        expect(response).to render_template('dwp_checks/new')
      end
    end
  end

  context 'logged in as admin user' do
    before(:each) { sign_in admin_user }
    describe 'GET #show' do
      it 'should assign the requested dwp_check as @dwp_check' do
        dwp_check = DwpCheck.create! valid_attributes
        get :show, {:unique_number => dwp_check.unique_number}, valid_session
        expect(assigns(:dwp_checker)).to eq(dwp_check)
        expect(response).to render_template('dwp_checks/show')
      end
    end
    describe 'GET #new' do
      it 'should render the expected view' do
        get :new, {}, valid_session
        expect(response.status).to eql(200)
        expect(response).to render_template('dwp_checks/new')
      end
    end
  end
end
