require 'rails_helper'

RSpec.describe ReportsController do
  let(:admin)     { create(:admin_user) }
  let(:date_from) { { day: "01", month: "01", year: "2015" } }
  let(:date_to) { { day: "31", month: "12", year: "2015" } }
  let(:dates) {
    { day_date_from: '01',
      month_date_from: '01',
      year_date_from: '2015',
      day_date_to: '31',
      month_date_to: '12',
      year_date_to: '2015' }
  }

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

        it { is_expected.to be_a Forms::FinanceReport }
      end
    end

    describe 'PUT #finance_report' do

      subject { response }

      context 'with invalid data - nil date from' do
        let(:dates) {
          { day_date_from: nil,
            month_date_from: nil,
            year_date_from: nil,
            day_date_to: '31',
            month_date_to: '12',
            year_date_to: '2015' }
        }
        before { put :finance_report_generator, params: { forms_finance_report: dates } }

        it { is_expected.to have_http_status(:success) }

        it { is_expected.to render_template :finance_report }
      end

      context 'with valid data - both from and to dates' do
        before { put :finance_report_generator, params: { forms_finance_report: dates } }

        it { is_expected.to have_http_status(:success) }

        it 'sets the filename' do
          expect(response.headers['Content-Disposition']).to include('finance-report-')
        end

        it 'sets the file type' do
          expect(response.headers['Content-Type']).to include('text/csv')
        end
      end

      context 'filters' do

        context 'with filters' do
          let(:filters) { { sop_code: 'ABC123', refund: 'true', application_type: 'income', jurisdiction_id: '1' } }

          it 'sends filter to DataReport' do
            report_params = dates.merge(filters)
            allow(FinanceReportBuilder).to receive(:new).and_return ['report']
            put :finance_report_generator, params: { forms_finance_report: report_params }
            expect(FinanceReportBuilder).to have_received(:new).with(date_from, date_to, filters)
          end
        end

        context 'only with present filters' do
          let(:filters) { { jurisdiction_id: '1' } }

          it 'sends filter to DataReport' do
            allow(FinanceReportBuilder).to receive(:new).and_return ['report']
            report_params = dates.merge(filters)

            put :finance_report_generator, params: { forms_finance_report: report_params }
            expect(FinanceReportBuilder).to have_received(:new).with(date_from, date_to, jurisdiction_id: '1')
          end
        end

        context 'no filters' do
          let(:filters) { {} }

          it 'sends filter to DataReport' do
            report_params = dates.merge(filters)
            allow(FinanceReportBuilder).to receive(:new).and_return ['report']
            put :finance_report_generator, params: { forms_finance_report: report_params }
            expect(FinanceReportBuilder).to have_received(:new).with(date_from, date_to, {})
          end
        end

      end
    end

    describe 'GET #finance_transactional_report' do
      before { get :finance_transactional_report }

      subject { response }

      it { is_expected.to have_http_status(:success) }
      it { is_expected.to render_template :finance_transactional_report }

      describe 'assigns form object' do
        subject { assigns(:form) }

        it { is_expected.to be_a Forms::Report::FinanceTransactionalReport }
      end
    end

    describe 'PUT #finance_transactional_report' do

      subject { response }

      context 'with invalid data - nil date from' do
        before { put :finance_transactional_report_generator, params: { forms_report_finance_transactional_report: { date_from: nil, date_to: '2018-12-31' } } }

        it { is_expected.to have_http_status(:success) }
        it { is_expected.to render_template :finance_transactional_report }
      end

      context 'with valid data - both from and to dates' do
        before { put :finance_transactional_report_generator, params: { forms_report_finance_transactional_report: dates } }

        it { is_expected.to have_http_status(:success) }

        it 'sets the filename' do
          expect(response.headers['Content-Disposition']).to include('finance-transactional-report-')
        end

        it 'sets the file type' do
          expect(response.headers['Content-Type']).to include('text/csv')
        end
      end

      context 'filters' do
        context 'with filters' do
          let(:filters) { { sop_code: 'ABC123', refund: 'true', application_type: 'income', jurisdiction_id: '1' } }

          it 'sends filter to DataReport' do
            report_params = dates.merge(filters)
            allow(FinanceTransactionalReportBuilder).to receive(:new).and_return ['report']
            put :finance_transactional_report_generator, params: { forms_report_finance_transactional_report: report_params }
            expect(FinanceTransactionalReportBuilder).to have_received(:new).with(date_from, date_to, filters)
          end
        end

        context 'only with present filters' do
          let(:filters) { { jurisdiction_id: '1' } }

          it 'sends filter to DataReport' do
            allow(FinanceTransactionalReportBuilder).to receive(:new).and_return ['report']
            report_params = dates.merge(filters)

            put :finance_transactional_report_generator, params: { forms_report_finance_transactional_report: report_params }
            expect(FinanceTransactionalReportBuilder).to have_received(:new).with(date_from, date_to, jurisdiction_id: '1')
          end
        end

        context 'no filters' do
          let(:filters) { {} }

          it 'sends filter to DataReport' do
            report_params = dates.merge(filters)
            allow(FinanceTransactionalReportBuilder).to receive(:new).and_return ['report']
            put :finance_transactional_report_generator, params: { forms_report_finance_transactional_report: report_params }
            expect(FinanceTransactionalReportBuilder).to have_received(:new).with(date_from, date_to, {})
          end
        end
      end
    end

    describe 'GET #graphs' do
      before { get :graphs }

      subject { response }

      it { is_expected.to have_http_status(:success) }

      it { is_expected.to render_template :graphs }

      it 'populates a list of report_data' do
        expect(assigns(:report_data).count).to eq 1
      end
    end

    describe 'GET #public' do
      before { get :public }

      subject { response }

      it { is_expected.to have_http_status(:success) }

      it { is_expected.to render_template :public }
    end

    describe 'GET #letters' do
      before { get :letters }

      subject { response }

      it { is_expected.to have_http_status(:success) }

      it { is_expected.to render_template :letters }
    end

    describe 'GET #raw_data' do
      before { get :raw_data }

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
        let(:dates) {
          { day_date_from: nil,
            month_date_from: nil,
            year_date_from: nil,
            day_date_to: '31',
            month_date_to: '12',
            year_date_to: '2015' }
        }

        before { put :raw_data_export, params: { forms_finance_report: dates } }

        it { is_expected.to have_http_status(:success) }

        it { is_expected.to render_template :raw_data }
      end

      context 'with valid data - both from and to dates' do
        before { put :raw_data_export, params: { forms_finance_report: dates } }

        it { is_expected.to have_http_status(:success) }

        it 'sets the filename' do
          expect(response.headers['Content-Disposition']).to include('help-with-fees-extract-')
        end

        it 'sets the file type' do
          expect(response.headers['Content-Type']).to include('text/csv')
        end
      end
    end
  end
end
