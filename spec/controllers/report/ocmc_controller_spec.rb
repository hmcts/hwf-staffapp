require 'rails_helper'

RSpec.describe Report::OcmcController do

  let(:admin)     { create(:admin_user) }
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
  let(:entity_code) { office.id }
  let(:office) { create(:office, entity_code: 'GE401') }
  let(:hmrc_office) { create(:office, entity_code: Settings.evidence_check.hmrc.office_entity_code) }

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

        it { is_expected.to render_template 'reports/ocmc_report' }
      end

      context 'income claims builder' do
        let(:dates) {
          { day_date_from: '01',
            month_date_from: '01',
            year_date_from: '2015',
            day_date_to: '31',
            month_date_to: '12',
            year_date_to: '2015',
            entity_code: office.id }
        }
        it 'does something' do
          allow(Views::Reports::HmrcOcmcDataExport).to receive(:new).and_return([])
          put :data_export, params: { forms_finance_report: dates }
          expect(Views::Reports::HmrcOcmcDataExport).to have_received(:new).with(date_from, date_to, office.id.to_s)
        end
      end

      context 'HMRC export with valid data - both from and to dates' do
        let(:entity_code) { hmrc_office.id }
        before {
          allow(Views::Reports::HmrcOcmcDataExport).to receive(:new).and_return([])
          put :data_export, params: { forms_finance_report: dates }
        }

        it { is_expected.to have_http_status(:success) }

      end
      context 'with valid data - both from and to dates' do
        before {
          allow(Views::Reports::HmrcOcmcDataExport).to receive(:new).and_return([])
          put :data_export, params: { forms_finance_report: dates }
        }

        it { is_expected.to have_http_status(:success) }

        context 'ccmcc office' do
          it 'sets the filename' do
            expect(response.headers['Content-Disposition']).to include("help-with-fees-#{entity_code}-applications-by-court-extract-")
          end
        end

        it 'sets the file type' do
          expect(response.headers['Content-Type']).to include('text/csv')
        end
      end
    end
  end
end
