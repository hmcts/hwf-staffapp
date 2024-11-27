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
        before { allow(RawDataExportJob).to receive(:perform_later) }

        let(:dates) {
          { day_date_from: '01',
            month_date_from: '01',
            year_date_from: '2020',
            day_date_to: '31',
            month_date_to: '12',
            year_date_to: '2022' }
        }

        context 'when exporting for all offices' do
          before { put :data_export, params: { forms_finance_report: dates.merge(all_offices: true) } }

          it { is_expected.to have_http_status(:redirect) }
          it { expect(flash[:notice]).to eq('Raw data export in progress. You should receive an email with a download link in a few minutes. If not received, please contact technical support.') }

          it "runs all offices export in delayed job" do
            from = { day: "01", month: "01", year: "2020" }
            to = { day: "31", month: "12", year: "2022" }

            expect(RawDataExportJob).to have_received(:perform_later).with(from: from, to: to, user_id: admin.id, court_id: nil)
          end
        end

        context 'when exporting for one office' do
          before { put :data_export, params: { forms_finance_report: dates.merge(all_offices: false, entity_code: '2') } }

          it { is_expected.to have_http_status(:redirect) }
          it { expect(flash[:notice]).to eq('Raw data export in progress. You should receive an email with a download link in a few minutes. If not received, please contact technical support.') }

          it "runs one office export in delayed job" do
            from = { day: "01", month: "01", year: "2020" }
            to = { day: "31", month: "12", year: "2022" }

            expect(RawDataExportJob).to have_received(:perform_later).with(from: from, to: to, user_id: admin.id, court_id: '2')
          end
        end
      end
    end
  end
end
