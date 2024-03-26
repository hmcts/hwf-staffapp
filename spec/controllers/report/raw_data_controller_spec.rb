require 'rails_helper'

RSpec.describe Report::RawDataController do

  let(:dates) {
    { day_date_from: nil,
      month_date_from: nil,
      year_date_from: nil,
      day_date_to: '31',
      month_date_to: '12',
      year_date_to: '2015' }
  }

  context 'manger user' do
    let(:manager) { create(:manager) }
    before { sign_in manager }

    describe 'GET #raw_data' do
      before { get :show }

      subject { response }
      it { is_expected.to have_http_status(:redirect) }
    end

    describe 'PUT #raw_data' do
      before { put :data_export, params: { forms_finance_report: dates } }

      subject { response }
      it { is_expected.to have_http_status(:redirect) }
    end
  end

  context 'admin' do
    let(:admin) { create(:admin_user) }
    before { sign_in admin }

    describe 'GET #raw_data' do
      before { get :show }

      subject { response }

      it { is_expected.to have_http_status(:success) }

      it { is_expected.to render_template :raw_data }
    end

    describe 'GET #show' do
      before { get :show }

      subject { response }

      it { is_expected.to have_http_status(:success) }

      it { is_expected.to render_template :raw_data }

      describe 'assigns form object' do
        subject { assigns(:form) }

        it { is_expected.to be_a Forms::FinanceReport }
      end
    end

    describe 'PUT #raw_data' do
      subject { response }

      context 'with invalid data - nil date from' do

        before { put :data_export, params: { forms_finance_report: dates } }

        it { is_expected.to have_http_status(:success) }

        it { is_expected.to render_template :raw_data }
      end

      context 'with valid data - both from and to dates' do
        before { put :data_export, params: { forms_finance_report: dates } }

        let(:dates) {
          { day_date_from: '01',
            month_date_from: '01',
            year_date_from: '2020',
            day_date_to: '31',
            month_date_to: '12',
            year_date_to: '2022' }
        }

        it { is_expected.to have_http_status(:success) }

        # it 'sets the filename' do
        #   expect(response.headers['Content-Disposition']).to include('raw_data-01-01-2020-31-12-2022.csv.zip')
        # end

        # it 'sets the file type' do
        #   expect(response.headers['Content-Type']).to include('application/zip')
        # end
      end
    end
  end
end
