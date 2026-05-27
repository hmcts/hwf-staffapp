require 'rails_helper'

RSpec.describe ApplicationsByCourtExportJob do
  let(:app_insight) { instance_double(ApplicationInsights::TelemetryClient, flush: '') }
  let(:mailer) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }
  let(:export) { instance_double(Views::Reports::ApplicationsByCourtExport, to_zip: 'zip_file', zipfile_path: '.') }
  let(:storage) { instance_double(ExportFileStorage, export_file: export_file, save!: true, id: '123') }
  let(:export_file) { instance_double(ActiveStorage::Attached::One, attach: true) }
  let(:user) { create(:user) }

  before do
    allow(ApplicationInsights::TelemetryClient).to receive(:new).and_return app_insight
    allow(app_insight).to receive(:track_event)
    allow(Views::Reports::ApplicationsByCourtExport).to receive(:new).and_return export
    allow(NotifyMailer).to receive(:file_report_ready).and_return mailer
    allow(ExportFileStorage).to receive(:new).and_return storage
  end

  describe '#perform' do
    it "run the export query" do
      described_class.perform_now(from: '1', to: '2', user_id: user.id, all_offices: true)
      expect(Views::Reports::ApplicationsByCourtExport).to have_received(:new).with('1', '2', nil, { :all_offices => true })
    end

    it "run the store file" do
      described_class.perform_now(from: '1', to: '2', user_id: user.id)
      expect(ExportFileStorage).to have_received(:new).with(user: user, name: 'ApplicationsByCourt')
      expect(storage).to have_received(:save!)
    end

    context 'notifications' do
      before { described_class.perform_now(from: '1', to: '1', user_id: user.id) }
      it { expect(mailer).to have_received(:deliver_now) }
      it { expect(app_insight).to have_received(:track_event).with("Running ApplicationsByCourtExport start at #{Time.zone.now.to_fs(:db)}") }
      it { expect(app_insight).to have_received(:track_event).with("Running ApplicationsByCourtExport end at #{Time.zone.now.to_fs(:db)}") }
      it { expect(app_insight).to have_received(:track_event).with("Sending ApplicationsByCourtExport email notification at #{Time.zone.now.to_fs(:db)}") }
    end

    it 'forwards a specific court_id to the export' do
      described_class.perform_now(court_id: 42, from: '1', to: '2', user_id: user.id)
      expect(Views::Reports::ApplicationsByCourtExport).to have_received(:new).with('1', '2', 42, { all_offices: nil })
    end

    it 'attaches the zip with the expected filename' do
      described_class.perform_now(from: '1', to: '2', user_id: user.id)
      expect(export_file).to have_received(:attach).with(hash_including(filename: 'ApplicationsByCourt.zip'))
    end

    context 'when the export raises' do
      let(:boom) { StandardError.new('boom') }

      let(:sentry_scope) { instance_double(Sentry::Scope, set_tags: true).as_null_object }

      before do
        allow(export).to receive(:to_zip).and_raise(boom)
        allow(Sentry).to receive(:with_scope).and_yield(sentry_scope)
        allow(Sentry).to receive(:capture_message)
        allow(Rails.logger).to receive(:debug)
        described_class.perform_now(from: '1', to: '2', user_id: user.id)
      end

      it 'reports the error to Sentry' do
        expect(Sentry).to have_received(:capture_message).with('boom')
      end

      it 'does not send an email notification' do
        expect(mailer).not_to have_received(:deliver_now)
      end

      it 'still logs the end event' do
        expect(app_insight).to have_received(:track_event).with("Running ApplicationsByCourtExport end at #{Time.zone.now.to_fs(:db)}")
      end
    end

    context 'when the user does not exist' do
      it 'raises RecordNotFound' do
        expect {
          described_class.perform_now(from: '1', to: '2', user_id: 0)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
