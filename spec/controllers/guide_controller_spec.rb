require 'rails_helper'

RSpec.describe GuideController, type: :controller do

  describe 'as a signed out user' do
    context 'index' do
      before { get :index }
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to render_template :index }
    end

    context 'appeals' do
      before { get :appeals }
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to render_template :appeals }
    end

    context 'evidence_checks' do
      before { get :evidence_checks }
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to render_template :evidence_checks }
    end

    context 'part_payments' do
      before { get :part_payments }
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to render_template :part_payments }
    end

    context 'process_application' do
      before { get :process_application }
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to render_template :process_application }
    end

    context 'suspected_fraud' do
      before { get :suspected_fraud }
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to render_template :suspected_fraud }
    end
  end

  describe 'as a signed in user' do

    before do
      sign_in create :user
      get :index
    end

    describe 'GET #index' do
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'renders the correct view' do
        expect(response).to render_template :index
      end
    end
  end
end
