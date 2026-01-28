require 'rails_helper'

RSpec.describe Report::HmrcController do

  context 'mi user' do
    let(:user) { create(:user) }
    before { sign_in user }

    describe 'GET #hmrc' do
      before { get :show }

      subject { response }
      it { is_expected.to have_http_status(:redirect) }
    end

    describe 'PUT #hmrc' do
      before { put :data_export }

      subject { response }
      it { is_expected.to have_http_status(:redirect) }
    end
  end

  context 'admin' do
    let(:admin) { create(:admin_user) }
    before { sign_in admin }

    describe 'GET #hmrc' do
      before { get :show }

      subject { response }

      it { is_expected.to have_http_status(:success) }

      it { is_expected.to render_template :hmrc }
    end

    describe 'PUT #data_export' do
      subject { response }
      let(:hmrc_export_class) { instance_double(Views::Reports::HmrcPurgedExport) }
      let(:report) { 'csv_file' }
      let(:current_time) { Time.zone.parse('2020-03-01 10:20:30') }

      before {
        allow(Views::Reports::HmrcPurgedExport).to receive(:new).and_return hmrc_export_class
        allow(hmrc_export_class).to receive(:to_csv).and_return report
        travel_to(current_time) do
          put :data_export
        end
      }

      it { is_expected.to have_http_status(:success) }

      it 'report for year date range' do
        date_from = Time.zone.parse('2019-03-01 0:00:00')
        date_to = Time.zone.parse('2020-03-01 10:20:30')

        expect(Views::Reports::HmrcPurgedExport).to have_received(:new).with(date_from, date_to)
      end

      it 'generate report to csv' do
        expect(hmrc_export_class).to have_received(:to_csv)
      end

    end
  end
end
