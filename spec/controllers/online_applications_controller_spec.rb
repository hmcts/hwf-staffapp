require 'rails_helper'

RSpec.describe OnlineApplicationsController, type: :controller do
  include Devise::TestHelpers

  let(:user) { create :user }
  let(:online_application) { build_stubbed(:online_application) }

  before do
    sign_in user
  end

  describe 'GET #edit' do
    let(:form) { double }

    before do
      allow(OnlineApplication).to receive(:find).with(online_application.id.to_s).and_return(online_application)
      allow(OnlineApplication).to receive(:find).with('non-existent').and_raise(ActiveRecord::RecordNotFound)
      allow(Forms::OnlineApplication).to receive(:new).with(online_application).and_return(form)

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
    end
  end
end
