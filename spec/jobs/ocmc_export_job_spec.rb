require 'rails_helper'

RSpec.describe OcmcExportJob do
  let(:app_insight) { instance_double(ApplicationInsights::TelemetryClient, flush: '') }
  let(:mailer) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }
  let(:hmrc_export) { instance_double(Views::Reports::HmrcOcmcDataExport, to_zip: 'zip_file', zipfile_path: '.') }
  let(:storage) { instance_double(ExportFileStorage, export_file: export_file, save: true, id: '123') }
  let(:export_file) { instance_double(ActiveStorage::Attached::One, attach: true) }
  let(:user) { create(:user) }

  before do
    allow(ApplicationInsights::TelemetryClient).to receive(:new).and_return app_insight
    allow(app_insight).to receive(:track_event)
    allow(Views::Reports::HmrcOcmcDataExport).to receive(:new).and_return hmrc_export
    allow(NotifyMailer).to receive(:file_report_ready).and_return mailer
    allow(ExportFileStorage).to receive(:new).and_return storage
  end

  describe '#perform' do
    it "run the export query" do
      described_class.perform_now(from: '1', to: '2', user_id: user.id, all_offices: true, all_datashare_offices: false)
      expect(Views::Reports::HmrcOcmcDataExport).to have_received(:new).with('1', '2', nil, { :all_offices => true, :all_datashare_offices => false })
    end

    it "run the store file" do
      described_class.perform_now(from: '1', to: '2', user_id: user.id)
      expect(ExportFileStorage).to have_received(:new).with(user: user, name: 'OCMC')
      expect(storage).to have_received(:save)
    end

    context 'notifications' do
      before { described_class.perform_now(from: '1', to: '1', user_id: user.id) }
      it { expect(mailer).to have_received(:deliver_now) }
      it { expect(app_insight).to have_received(:track_event).with("Running OCMCExport start at #{Time.zone.now.to_fs(:db)}") }
      it { expect(app_insight).to have_received(:track_event).with("Running OCMCExport end at #{Time.zone.now.to_fs(:db)}") }
      it { expect(app_insight).to have_received(:track_event).with("Sending OCMCExport email notification at #{Time.zone.now.to_fs(:db)}") }
    end

  end
end
