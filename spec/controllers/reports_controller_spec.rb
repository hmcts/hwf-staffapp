require 'rails_helper'

RSpec.describe ReportsController, type: :controller do

  include Devise::TestHelpers

  let(:admin)     { create :admin_user }

  it_behaves_like 'Pundit denies access to', :index
  it_behaves_like 'Pundit denies access to', :finance_report

  context 'as an admin' do
    before { sign_in admin }

    describe 'GET #index' do
      before { get :index }

      subject { response }

      it { is_expected.to have_http_status(:success) }

      it { is_expected.to render_template :index }
    end

    describe 'GET #finance_report' do
      before { get :finance_report }

      subject { response }

      it { is_expected.to have_http_status(:success) }

      it { is_expected.to render_template :finance_report }

      describe 'assigns form object' do
        subject { assigns(:form) }

        it { is_expected.to be_a_kind_of Forms::FinanceReport }
      end
    end

    describe 'PUT #finance_report' do
      before { put :finance_report }

      subject { response }

      it { is_expected.to have_http_status(:success) }

      it { is_expected.to render_template :finance_report }
    end
  end
end
