require 'rails_helper'

RSpec.describe Report::PowerBiController do

  context 'mi user' do
    let(:mi) { create(:mi) }
    before { sign_in mi }

    describe 'GET #power_bi' do
      before { get :show }

      subject { response }
      it { is_expected.to have_http_status(:redirect) }
    end

    describe 'PUT #power_bi' do
      before { put :data_export }

      subject { response }
      it { is_expected.to have_http_status(:redirect) }
    end
  end

  context 'admin' do
    let(:admin) { create(:admin_user) }
    before { sign_in admin }

    describe 'GET #power_bi' do
      before { get :show }

      subject { response }

      it { is_expected.to have_http_status(:success) }

      it { is_expected.to render_template :power_bi }
    end

    describe 'PUT #power_bi_export' do
      subject { response }
      let(:export1) { instance_double(Views::Reports::PowerBiExport1) }
      let(:export2) { instance_double(Views::Reports::PowerBiExport2) }
      let(:export3) { instance_double(Views::Reports::PowerBiExport3) }
      let(:temp_file) { Tempfile.new('foo') }

      before {
        allow(export1).to receive(:to_zip)
        allow(export1).to receive(:zipfile_path).and_return temp_file.path
        allow(Views::Reports::PowerBiExport1).to receive(:new).and_return export1
        allow(export2).to receive(:to_zip)
        allow(export2).to receive(:zipfile_path).and_return temp_file.path
        allow(Views::Reports::PowerBiExport2).to receive(:new).and_return export2
        allow(export3).to receive(:to_zip)
        allow(export3).to receive(:zipfile_path).and_return temp_file.path
        allow(Views::Reports::PowerBiExport3).to receive(:new).and_return export3
      }

      context 'when no export is chosen' do
        before { put :data_export }

        it { is_expected.to have_http_status(:success) }

        it 'defaults to export 1' do
          expect(export1).to have_received(:zipfile_path)
        end
      end

      context 'when export 1 is chosen' do
        before { put :data_export, params: { export_type: '1' } }

        it 'generates export 1' do
          expect(export1).to have_received(:zipfile_path)
        end
      end

      context 'when export 2 is chosen' do
        before { put :data_export, params: { export_type: '2' } }

        it { is_expected.to have_http_status(:success) }

        it 'generates export 2' do
          expect(export2).to have_received(:zipfile_path)
        end
      end

      context 'when export 3 is chosen' do
        before { put :data_export, params: { export_type: '3' } }

        it { is_expected.to have_http_status(:success) }

        it 'generates export 3' do
          expect(export3).to have_received(:zipfile_path)
        end
      end

      context 'when a specific month is chosen' do
        before { put :data_export, params: { export_type: '1', month: '2025-11' } }

        it 'builds the export for that month' do
          expect(Views::Reports::PowerBiExport1).to have_received(:new).with(Date.new(2025, 11, 1))
        end
      end

      context 'when no month is chosen' do
        before { travel_to(Date.new(2026, 5, 15)) { put :data_export, params: { export_type: '1' } } }

        it 'defaults to the previous month (April)' do
          expect(Views::Reports::PowerBiExport1).to have_received(:new).with(Date.new(2026, 4, 1))
        end
      end
    end
  end
end
