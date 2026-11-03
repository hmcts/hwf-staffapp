require 'rails_helper'

RSpec.describe Report::PowerBiController do

  context 'mi user' do
    let(:mi) { create(:mi) }
    before { sign_in mi }

    describe 'GET #index' do
      before { get :index }

      subject { response }
      it { is_expected.to have_http_status(:redirect) }
    end

    describe 'GET #show' do
      before { get :show, params: { export_type: '1' } }

      subject { response }
      it { is_expected.to have_http_status(:redirect) }
    end

    describe 'PUT #data_export' do
      before { put :data_export, params: { export_type: '1' } }

      subject { response }
      it { is_expected.to have_http_status(:redirect) }
    end
  end

  context 'admin' do
    let(:admin) { create(:admin_user) }
    before { sign_in admin }

    describe 'GET #index' do
      before { get :index }

      subject { response }

      it { is_expected.to have_http_status(:success) }
      it { is_expected.to render_template 'reports/power_bi/index' }
    end

    describe 'GET #show' do
      before { get :show, params: { export_type: '2' } }

      subject { response }

      it { is_expected.to have_http_status(:success) }
      it { is_expected.to render_template 'reports/power_bi/show' }
    end

    describe 'PUT #data_export' do
      subject { response }

      before { allow(PowerBiExportJob).to receive(:perform_later) }

      context 'when export 2 is requested' do
        before { put :data_export, params: { export_type: '2', month: '2026-10' } }

        it 'builds the export in the background for that month and user' do
          expect(PowerBiExportJob).to have_received(:perform_later).
            with(export_type: '2', month: Date.new(2026, 10, 1), user_id: admin.id)
        end

        it 'goes back to the Power BI page saying an email is on its way' do
          expect(response).to redirect_to(report_power_bi_path)
          expect(flash[:notice]).to eq I18n.t('forms/report/power_bi.notice')
        end
      end

      context 'when no month is chosen' do
        before { travel_to(Date.new(2026, 5, 15)) { put :data_export, params: { export_type: '1' } } }

        it 'defaults to the previous month (April)' do
          expect(PowerBiExportJob).to have_received(:perform_later).
            with(export_type: '1', month: Date.new(2026, 4, 1), user_id: admin.id)
        end
      end
    end
  end
end
