require 'rails_helper'

RSpec.describe DwpChecksController, type: :controller do

  include Devise::TestHelpers

  # This return the minimal set of values that be in the session
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
        get :show, { unique_number: dwp_check.to_param }, valid_session
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
      it 'assign the requested dwp_check as @dwp_check' do
        dwp_check = DwpCheck.create! valid_attributes
        get :show, { unique_number: dwp_check.unique_number }, valid_session
        expect(assigns(:dwp_checker)).to eq(dwp_check)
        expect(response).to render_template('dwp_checks/show')
      end
    end
    describe 'GET #new' do
      it 'render the expected view' do
        get :new, {}, valid_session
        expect(response.status).to eql(200)
        expect(response).to render_template('dwp_checks/new')
      end
    end
  end

  context 'logged in as admin user' do
    before(:each) { sign_in admin_user }
    describe 'GET #show' do
      it 'assign the requested dwp_check as @dwp_check' do
        dwp_check = DwpCheck.create! valid_attributes
        get :show, { unique_number: dwp_check.unique_number }, valid_session
        expect(assigns(:dwp_checker)).to eq(dwp_check)
        expect(response).to render_template('dwp_checks/show')
      end
    end
    describe 'GET #new' do
      it 'render the expected view' do
        get :new, {}, valid_session
        expect(response.status).to eql(200)
        expect(response).to render_template('dwp_checks/new')
      end
    end
  end

  context 'logged in as standard user' do
    before(:each) { sign_in user }

    describe 'POST #lookup' do
      context 'valid request' do

        let(:dwp_params) do
          {
            last_name: 'last_name',
            dob: '1980-01-01',
            ni_number: 'AB123456A',
            date_to_check: "#{Date.today}"
          }
        end

        before(:each) { post :lookup, dwp_check: dwp_params }

        it 'should return the redirect status code' do
          expect(response.status).to eql(302)
        end

        it 'should return the redirect status code' do
          expect(response).to redirect_to dwp_checks_path(DwpCheck.last.unique_number)
        end
      end

      context 'invalid request' do
        let(:dwp_params) do
          {
            last_name: 'last_name',
            dob: '1980-01-01',
            ni_number: '',
            date_to_check: "#{Date.today}"
          }
        end

        before(:each) { post :lookup, dwp_check: dwp_params }

        it 'should re-render the form' do
          expect(response).to render_template(:new)
        end
      end
    end
  end
end
