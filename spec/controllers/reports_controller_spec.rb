require 'rails_helper'

RSpec.describe ReportsController, type: :controller do
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
      before { put :finance_report_generator, forms_finance_report: { date_from: '2015-01-01', date_to: '2015-12-31' } }

      subject { response }

      it { is_expected.to have_http_status(:success) }

      it 'sets the filename' do
        expect(response.headers['Content-Disposition']).to include('finance-report-')
      end
      it 'sets the filename' do
        expect(response.headers['Content-Type']).to include('text/csv')
      end
    end

    describe 'GET #graphs' do
      before { get :graphs }

      subject { response }

      it { is_expected.to have_http_status(:success) }

      it { is_expected.to render_template :graphs }

      it 'populates a list of report_data' do
        expect(assigns(:report_data).count).to eql(1)
      end
    end

    describe 'GET #public' do
      before { get :public }

      subject { response }

      it { is_expected.to have_http_status(:success) }

      it { is_expected.to render_template :public }
    end
  end
end
