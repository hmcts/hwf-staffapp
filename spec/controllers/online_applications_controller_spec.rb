require 'rails_helper'

RSpec.describe OnlineApplicationsController, type: :controller do
  include Devise::TestHelpers

  let(:user) { create :user }
  let(:online_application) { build_stubbed(:online_application) }
  let(:jurisdiction) { build_stubbed(:jurisdiction) }
  let(:form) { double }

  before do
    allow(OnlineApplication).to receive(:find).with(online_application.id.to_s).and_return(online_application)
    allow(OnlineApplication).to receive(:find).with('non-existent').and_raise(ActiveRecord::RecordNotFound)
    allow(Forms::OnlineApplication).to receive(:new).with(online_application).and_return(form)

    sign_in user
  end

  describe 'GET #edit' do
    before do
      get :edit, id: id
    end

    context 'when no online application is found with the id' do
      let(:id) { 'non-existent' }

      it 'redirects to the homepage' do
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when an online application is found with the id' do
      let(:id) { online_application.id }

      it 'renders the edit template' do
        expect(response).to render_template(:edit)
      end

      it 'assigns the edit form' do
        expect(assigns(:form)).to eql(form)
      end

      it 'assigns the online_application' do
        expect(assigns(:online_application)).to eql(online_application)
      end

      it 'assigns the user\'s office jurisdictions' do
        expect(assigns(:jurisdictions)).to eq(user.office.jurisdictions)
      end
    end
  end

  describe 'PUT #update' do
    let(:params) { {} }
    let(:form_save) { false }

    before do
      allow(form).to receive(:update_attributes).with(params)
      allow(form).to receive(:save).and_return(form_save)

      put :update, id: id, online_application: params
    end

    context 'when no online application is found with the id' do
      let(:id) { 'non-existent' }

      it 'redirects to the homepage' do
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when an online application is found with the id' do
      let(:params) { { fee: '100', jurisdiction_id: jurisdiction.id.to_s } }
      let(:id) { online_application.id }

      context 'when the form can be saved' do
        let(:form_save) { true }

        it 'temporarily renders the edit template' do
          expect(response).to render_template(:edit)
        end

        it 'renders a success flash message' do
          expect(flash[:notice]).to eql('Application has been saved.')
        end
      end

      context 'when the form can not be saved' do
        it 'renders the edit template' do
          expect(response).to render_template(:edit)
        end

        it 'assigns the form' do
          expect(assigns(:form)).to eql(form)
        end

        it 'assigns the online_application' do
          expect(assigns(:online_application)).to eql(online_application)
        end

        it 'assigns the user\'s office jurisdictions' do
          expect(assigns(:jurisdictions)).to eq(user.office.jurisdictions)
        end
      end
    end
  end

  describe 'GET #show' do
    let(:overview) { double }

    before do
      allow(Views::ApplicationOverview).to receive(:new).with(online_application).and_return(overview)

      get :show, id: id
    end

    context 'when no online application is found with the id' do
      let(:id) { 'non-existent' }

      it 'redirects to the homepage' do
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when an online application is found with the id' do
      let(:id) { online_application.id }

      it 'renders the show template' do
        expect(response).to render_template(:show)
      end

      it 'assigns the overview view model' do
        expect(assigns(:overview)).to eql(overview)
      end
    end
  end
end
