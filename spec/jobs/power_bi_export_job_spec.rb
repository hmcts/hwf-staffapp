require 'rails_helper'

RSpec.describe PowerBiExportJob do
  let(:app_insight) { instance_double(ApplicationInsights::TelemetryClient, flush: '') }
  let(:mailer) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }
  let(:export) { instance_double(Views::Reports::PowerBiExport2, to_zip: 'zip_file', zipfile_path: '.', tidy_up: true) }
  let(:storage) { instance_double(ExportFileStorage, export_file: export_file, save!: true, id: '123') }
  let(:export_file) { instance_double(ActiveStorage::Attached::One, attach: true) }
  let(:user) { create(:user) }
  let(:month) { Date.new(2026, 10, 1) }

  before do
    allow(ApplicationInsights::TelemetryClient).to receive(:new).and_return app_insight
    allow(app_insight).to receive(:track_event)
    allow(Views::Reports::PowerBiExport2).to receive(:new).and_return export
    allow(NotifyMailer).to receive(:file_report_ready).and_return mailer
    allow(ExportFileStorage).to receive(:new).and_return storage
  end

  describe '#perform' do
    context 'when the export is built' do
      before { described_class.perform_now(export_type: '2', month: month, user_id: user.id) }

      it 'builds the chosen export for the month' do
        expect(Views::Reports::PowerBiExport2).to have_received(:new).with(month)
        expect(export).to have_received(:to_zip)
      end

      it 'stores the zip for the user' do
        expect(ExportFileStorage).to have_received(:new).with(user: user, name: 'power_bi_export_2')
        expect(storage).to have_received(:save!)
      end

      it 'emails the user a download link' do
        expect(NotifyMailer).to have_received(:file_report_ready).with(user, '123')
        expect(mailer).to have_received(:deliver_now)
      end

      it 'removes the zip from the server once it is stored' do
        expect(export).to have_received(:tidy_up)
      end
    end

    context 'when export 1 is chosen' do
      let(:export1) { instance_double(Views::Reports::PowerBiExport1, to_zip: 'zip_file', zipfile_path: '.', tidy_up: true) }

      before do
        allow(Views::Reports::PowerBiExport1).to receive(:new).and_return export1
        described_class.perform_now(export_type: '1', month: month, user_id: user.id)
      end

      it { expect(Views::Reports::PowerBiExport1).to have_received(:new).with(month) }
    end

    context 'when export 3 is chosen' do
      let(:export3) { instance_double(Views::Reports::PowerBiExport3, to_zip: 'zip_file', zipfile_path: '.', tidy_up: true) }

      before do
        allow(Views::Reports::PowerBiExport3).to receive(:new).and_return export3
        described_class.perform_now(export_type: '3', month: month, user_id: user.id)
      end

      it { expect(Views::Reports::PowerBiExport3).to have_received(:new).with(month) }
    end

    context 'when the export fails' do
      before do
        allow(export).to receive(:to_zip).and_raise(StandardError, 'boom')
        allow(Sentry).to receive(:capture_message)
        described_class.perform_now(export_type: '2', month: month, user_id: user.id)
      end

      it 'reports the error' do
        expect(Sentry).to have_received(:capture_message).with('boom')
      end

      it 'sends no email' do
        expect(mailer).not_to have_received(:deliver_now)
      end

      it 'still removes the zip from the server' do
        expect(export).to have_received(:tidy_up)
      end
    end
  end
end
