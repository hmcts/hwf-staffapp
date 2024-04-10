require 'rails_helper'

RSpec.describe FinanceTransactionalReportJob do
  let(:app_insight) { instance_double(ApplicationInsights::TelemetryClient, flush: '') }
  let(:mailer) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }
  let(:financial_report) { instance_double(FinanceTransactionalReportBuilder, to_zip: 'zip_file', zipfile_path: '.') }
  let(:storage) { instance_double(ExportFileStorage, export_file: export_file, save: true, id: '123') }
  let(:export_file) { instance_double(ActiveStorage::Attached::One, attach: true) }
  let(:user) { create(:user) }

  before do
    allow(ApplicationInsights::TelemetryClient).to receive(:new).and_return app_insight
    allow(app_insight).to receive(:track_event)
    allow(FinanceTransactionalReportBuilder).to receive(:new).and_return financial_report
    allow(NotifyMailer).to receive(:file_report_ready).and_return mailer
    allow(ExportFileStorage).to receive(:new).and_return storage
  end

  describe '#perform' do
    it "run the export query" do
      described_class.perform_now(from: '1', to: '2', user_id: user.id)
      expect(FinanceTransactionalReportBuilder).to have_received(:new).with('1', '2', {})
    end

    it "run the store file" do
      described_class.perform_now(from: '1', to: '2', user_id: user.id)
      expect(ExportFileStorage).to have_received(:new).with(user: user, name: 'finance_transactional')
      expect(storage).to have_received(:save)
    end

    context 'notifications' do
      before { described_class.perform_now(from: '1', to: '1', user_id: user.id) }
      it { expect(mailer).to have_received(:deliver_now) }
      it { expect(app_insight).to have_received(:track_event).with("Running Finance Transactional start at #{Time.zone.now.to_fs(:db)}") }
      it { expect(app_insight).to have_received(:track_event).with("Running Finance Transactional end at #{Time.zone.now.to_fs(:db)}") }
      it { expect(app_insight).to have_received(:track_event).with("Sending Finance Transactional email notification at #{Time.zone.now.to_fs(:db)}") }
    end

  end
end
