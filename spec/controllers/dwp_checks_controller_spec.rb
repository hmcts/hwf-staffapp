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
      dob: Date.today - 20.years,
      ni_number: 'AB123456C',
      date_to_check: nil,
      checked_by: nil,
      laa_code: nil,
      unique_number: nil
    }
  }

  let(:user)          { create :user }
  let(:admin_user)    { create :admin_user }

  context 'logged out user' do
    describe 'GET #show' do
      it 'redirects to login page' do
        dwp_check = create(:dwp_check, created_by: user)
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
        dwp_check = create(:dwp_check, created_by: user)
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
    describe 'POST #lookup' do

      before { WebMock.disable_net_connect!(allow: ['127.0.0.1', 'codeclimate.com', 'www.google.com/jsapi']) }

      context 'date format' do
        let(:dwp_params) do
          {
            last_name: 'last_name',
            dob: nil,
            ni_number: 'AB123456A',
            entitlement_check_date: "#{Date.today}"
          }
        end
        before(:each) do
          json = '{"original_client_ref": "unique", "benefit_checker_status": "Yes",
                  "confirmation_ref": "T1426267181940",
                  "@xmlns": "https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check"}'
          stub_request(:post, "#{ENV['DWP_API_PROXY']}/api/benefit_checks").
            to_return(status: 200, body: json, headers: {})
        end

        it "doesn't accepts d/m/yy date format" do
          dwp_params[:dob] = '1/1/80'
          post :lookup, dwp_check: dwp_params
          expect(response).to render_template('dwp_checks/new')
        end

        it 'accepts dd mmmm yyyy' do
          dwp_params[:dob] = '01 January 1980'
          post :lookup, dwp_check: dwp_params
          expect(response).to redirect_to dwp_checks_path(DwpCheck.last.unique_number)
        end
      end

      context 'valid request' do

        let(:dwp_params) do
          {
            last_name: 'last_name',
            dob: '1980-01-01',
            ni_number: 'AB123456A',
            entitlement_check_date: "#{Date.today}"
          }
        end

        before(:each) do
          json = '{"original_client_ref": "unique", "benefit_checker_status": "Yes",
                  "confirmation_ref": "T1426267181940",
                  "@xmlns": "https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check"}'
          stub_request(:post, "#{ENV['DWP_API_PROXY']}/api/benefit_checks").
            to_return(status: 200, body: json, headers: {})
          post :lookup, dwp_check: dwp_params
        end

        it 'returns the redirect status code' do
          expect(response.status).to eql(302)
        end

        it 'redirects to the result page' do
          expect(response).to redirect_to dwp_checks_path(DwpCheck.last.unique_number)
        end
        context 'when service encounters an error' do
          before(:each) do
            stub_request(:post, "#{ENV['DWP_API_PROXY']}/api/benefit_checks").
              to_return(status: 500, headers: {})
            post :lookup, dwp_check: dwp_params
          end
          it 're-renders the form' do
            expect(response).to render_template(:new)
          end
          it 'displays a flash message' do
            expect(flash[:alert]).to be_present
          end
          it 'displays the error description in the flash message' do
            expect(flash[:alert]).to eql('500 Internal Server Error')
          end
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

        it 're-renders the form' do
          expect(response).to render_template(:new)
        end
      end
    end
  end

  context 'logged in as admin user' do
    before(:each) { sign_in admin_user }
    describe 'GET #show' do
      it 'assign the requested dwp_check as @dwp_check' do
        dwp_check = create(:dwp_check, created_by: user)
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
end
