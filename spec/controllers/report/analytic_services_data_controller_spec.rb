require 'rails_helper'

RSpec.describe Report::AnalyticServicesDataController do

  let(:admin)     { create :admin_user }
  let(:date_from) { { day: "01", month: "01", year: "2015" } }
  let(:date_to) { { day: "31", month: "12", year: "2015" } }
  let(:dates) {
    { day_date_from: '01',
      month_date_from: '01',
      year_date_from: '2015',
      day_date_to: '31',
      month_date_to: '12',
      year_date_to: '2015',
      entity_code: entity_code }
  }
  let(:entity_code) { 'GE401' }

  context 'as an admin' do
    before { sign_in admin }
    describe 'PUT #data_export' do

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

        before { put :data_export, params: { forms_finance_report: dates } }

        it { is_expected.to have_http_status(:success) }

        it { is_expected.to render_template :analytic_services_data }
      end

      context 'fees_mechanical builder' do
        let(:dates) {
          { day_date_from: '01',
            month_date_from: '01',
            year_date_from: '2015',
            day_date_to: '31',
            month_date_to: '12',
            year_date_to: '2015',
            entity_code: entity_code }
        }
        it 'does something' do
          allow(Views::Reports::AnalyticServicesDataExport).to receive(:new).and_return([])
          put :data_export, params: { forms_finance_report: dates }
          expect(Views::Reports::AnalyticServicesDataExport).to have_received(:new).with(date_from, date_to, 'GE401')
        end
      end

      context 'with valid data - both from and to dates' do
        before { put :data_export, params: { forms_finance_report: dates } }

        it { is_expected.to have_http_status(:success) }

        context 'ccmcc office' do
          let(:entity_code) { 'DH403' }
          it 'sets the filename' do
            expect(response.headers['Content-Disposition']).to include('help-with-fees-ccmcc-data-extract-')
          end
        end

        context 'Birkenhead office' do
          let(:entity_code) { 'GE401' }
          it 'sets the filename' do
            expect(response.headers['Content-Disposition']).to include('help-with-fees-birkenhead-data-extract-')
          end
        end

        it 'sets the file type' do
          expect(response.headers['Content-Type']).to include('text/csv')
        end
      end
    end
  end
end
