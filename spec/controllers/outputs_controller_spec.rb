require 'rails_helper'

RSpec.describe OutputsController, type: :controller do

  include Devise::TestHelpers

  let(:admin)     { create :admin_user }
  let(:manager)   { create :manager }
  let(:user)      { create :user }

  describe 'GET #index' do
    context 'when user is invalid because' do
      subject { -> { get :index } }

      context 'they are not signed in' do
        before { get :index }

        subject { response }

        it { is_expected.to have_http_status(:redirect) }

        it { is_expected.to redirect_to(user_session_path) }
      end

      context 'as a user' do
        before { sign_in user }

        it { is_expected.to raise_error(CanCan::AccessDenied, 'You are not authorized to access this page.') }
      end

      context 'as a manager' do
        before { sign_in manager }

        it { is_expected.to raise_error(CanCan::AccessDenied, 'You are not authorized to access this page.') }
      end
    end

    context 'as an admin' do
      before do
        sign_in admin
        get :index
      end

      subject { response }

      it { is_expected.to have_http_status(:success) }

      it { is_expected.to render_template :index }
    end
  end
end
