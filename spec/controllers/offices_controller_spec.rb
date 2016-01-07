require 'rails_helper'

RSpec.describe OfficesController, type: :controller do

  include Devise::TestHelpers

  let(:user)        { create :user }
  let(:admin_user)  { create :admin_user }
  let(:manager)     { create :manager }
  let(:office)      { create(:office) }

  let(:jurisdiction) { create :jurisdiction }
  let(:valid_params) { attributes_for(:office).merge(jurisdiction_ids: [jurisdiction.id]) }

  context 'logged out user' do
    describe 'GET #index' do
      it 'redirects to login page' do
        get :index
        expect(response).to redirect_to(user_session_path)
      end
    end

    describe 'GET #show' do
      it 'redirects to login page' do
        get :show, id: office.to_param
        expect(response).to redirect_to(user_session_path)
      end
    end

    describe 'GET #new' do
      it 'redirects to login page' do
        get :index
        expect(response).to redirect_to(user_session_path)
      end
    end
  end

  context 'standard user' do
    before(:each) { sign_in user }

    describe 'GET #index' do
      it 'assigns all offices as @offices' do
        get :index
        expect(assigns(:offices)).to include(office)
      end
    end

    describe 'GET #show' do
      it 'assigns the requested office as @office' do
        get :show, id: office.to_param
        expect(assigns(:office)).to eq office
      end
    end

    describe 'GET #new' do
      it 'raises Pundit error' do
        bypass_rescue
        expect {
          bypass_rescue
          get :new
        }.to raise_error Pundit::NotAuthorizedError
      end
    end

    describe 'GET #edit' do
      it 'raises Pundit error' do
        expect {
          bypass_rescue
          get :edit, id: office.to_param
        }.to raise_error Pundit::NotAuthorizedError
      end
    end

    describe 'POST #create' do
      context 'with valid params' do
        it 'raises Pundit error' do
          expect {
            bypass_rescue
            post :create, office: valid_params
          }.to raise_error Pundit::NotAuthorizedError
        end
      end
    end

    describe 'PUT #update' do
      context 'with valid params' do
        it 'raises Pundit error' do
          expect {
            bypass_rescue
            put :update, id: office.to_param, office: valid_params
          }.to raise_error Pundit::NotAuthorizedError
        end
      end
    end
  end

  context 'as a manager' do
    before(:each) { sign_in manager }

    describe 'GET #index' do
      it 'assigns all offices as @offices' do
        get :index
        expect(assigns(:offices)).to include(office)
      end
    end

    describe 'GET #show' do
      it 'assigns the requested office as @office' do
        get :show, id: office.to_param
        expect(assigns(:office)).to eq office
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

    describe 'GET #edit' do
      context 'for their own office' do
        it 'assigns the requested office as @office' do
          get :edit, id: manager.office.to_param
          expect(assigns(:office)).to eq(manager.office)
        end
      end

      context 'for a different office' do
        it 'raises Pundit error' do
          expect {
            bypass_rescue
            get :edit, id: create(:office).to_param
          }.to raise_error Pundit::NotAuthorizedError
        end
      end
    end

    describe 'POST #create' do
      context 'with valid params' do
        it 'raises Pundit error' do
          expect {
            bypass_rescue
            post :create, office: valid_params
          }.to raise_error Pundit::NotAuthorizedError
        end
      end
    end

    describe 'PUT #update' do
      context 'with valid params' do
        it 'assigns the requested office as @office' do
          put :update, id: manager.office.to_param, office: valid_params
          expect(assigns(:office)).to eq(manager.office)
        end

        it 'redirects to the office' do
          put :update, id: manager.office.to_param, office: valid_params
          expect(response).to redirect_to(manager.office)
        end
      end

      context 'with invalid params' do
        it 'assigns the office as @office' do
          put :update, id: manager.office.to_param, office: attributes_for(:invalid_office)
          expect(assigns(:office)).to eq(manager.office)
        end

        it 're-renders the "edit" template' do
          put :update, id: manager.office.to_param, office: attributes_for(:invalid_office)
          expect(response).to render_template('edit')
        end
      end
    end
  end

  context 'admin user' do

    before(:each) { sign_in admin_user }

    describe 'GET #index' do
      it 'assigns all offices as @offices' do
        get :index
        expect(assigns(:offices)).to include(office)
      end
    end

    describe 'GET #show' do
      it 'assigns the requested office as @office' do
        get :show, id: office.to_param
        expect(assigns(:office)).to eq(office)
      end
    end

    describe 'GET #new' do
      it 'assigns a new office as @office' do
        get :new
        expect(assigns(:office)).to be_a_new(Office)
      end
    end

    describe 'GET #edit' do
      it 'assigns the requested office as @office' do
        get :edit, id: office.to_param
        expect(assigns(:office)).to eq(office)
      end
    end

    describe 'POST #create' do
      context 'with valid params' do
        it 'creates a new Office' do
          expect {
            post :create, office: valid_params
          }.to change(Office, :count).by(1)
        end

        it 'assigns a newly created office as @office' do
          post :create, office: valid_params
          expect(assigns(:office)).to be_a(Office)
          expect(assigns(:office)).to be_persisted
        end

        it 'redirects to the created office' do
          post :create, office: valid_params
          expect(response).to redirect_to(Office.last)
        end
      end

      context 'with invalid params' do
        it 'assigns a newly created but unsaved office as @office' do
          post :create, office: attributes_for(:invalid_office)
          expect(assigns(:office)).to be_a_new(Office)
        end

        it 're-renders the "new" template' do
          post :create, office: attributes_for(:invalid_office)
          expect(response).to render_template('new')
        end
      end
    end

    describe 'PUT #update' do
      context 'with valid params' do
        it 'updates the requested office' do
          put :update, id: office.to_param, office: attributes_for(:invalid_office)
          office.reload
        end

        it 'assigns the requested office as @office' do
          put :update, id: office.to_param, office: valid_params
          expect(assigns(:office)).to eq(office)
        end

        it 'redirects to the office' do
          put :update, id: office.to_param, office: valid_params
          expect(response).to redirect_to(office)
        end
      end

      context 'with invalid params' do
        it 'assigns the office as @office' do
          put :update, id: office.to_param, office: attributes_for(:invalid_office)
          expect(assigns(:office)).to eq(office)
        end

        it 're-renders the "edit" template' do
          put :update, id: office.to_param, office: attributes_for(:invalid_office)
          expect(response).to render_template('edit')
        end
      end
    end
  end
end
