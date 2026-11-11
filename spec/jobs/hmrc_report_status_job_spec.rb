require 'rails_helper'

RSpec.describe HmrcReportStatusJob do
  describe 'check HMRC status' do
    let(:app_insight) { instance_double(ApplicationInsights::TelemetryClient, flush: '') }
    let(:down_mail) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }
    let(:up_mail) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }
    let(:hmrc_monitor) { instance_double(HmrcMonitor, state: monitor_state) }
    let(:now) { Time.zone.local(2026, 11, 11, 9, 0, 0) }

    before do
      allow(ApplicationInsights::TelemetryClient).to receive(:new).and_return app_insight
      allow(app_insight).to receive(:track_event)
      allow(HmrcMonitor).to receive(:new).and_return hmrc_monitor
      allow(NotifyMailer).to receive_messages(hmrc_is_down_notifier: down_mail, hmrc_is_up_notifier: up_mail)
    end

    def run_job
      travel_to(now) { described_class.perform_now }
    end

    context 'offline' do
      let(:monitor_state) { 'offline' }

      before { run_job }

      it { expect(down_mail).to have_received(:deliver_now) }
      it { expect(up_mail).not_to have_received(:deliver_now) }
      it { expect(app_insight).to have_received(:track_event).with("Running HMRC status check at #{now.to_fs(:db)}") }
      it { expect(app_insight).to have_received(:track_event).with("Sending HMRC status is offline notication at #{now.to_fs(:db)}") }
    end

    context 'offline again on the next check, one minute later' do
      let(:monitor_state) { 'offline' }

      it 'does not send a second email' do
        run_job
        travel_to(now + 1.minute) { described_class.perform_now }
        expect(down_mail).to have_received(:deliver_now).once
      end
    end

    context 'online after an outage' do
      let(:monitor_state) { 'online' }

      before do
        StatusNotification.create!(service: 'hmrc', outage_open: true, sent_count: 4, last_sent_at: now - 10.minutes)
        run_job
      end

      it { expect(up_mail).to have_received(:deliver_now) }
      it { expect(down_mail).not_to have_received(:deliver_now) }
      it { expect(app_insight).to have_received(:track_event).with("Sending HMRC status is online notification at #{now.to_fs(:db)}") }
    end

    context 'online with no outage' do
      let(:monitor_state) { 'online' }

      before { run_job }

      it { expect(down_mail).not_to have_received(:deliver_now) }
      it { expect(up_mail).not_to have_received(:deliver_now) }
      it { expect(app_insight).to have_received(:track_event).with("Running HMRC status check at #{now.to_fs(:db)}") }
    end

    context 'warning' do
      let(:monitor_state) { 'warning' }

      before { run_job }

      it { expect(down_mail).not_to have_received(:deliver_now) }
      it { expect(up_mail).not_to have_received(:deliver_now) }
    end

    context 'when the email cannot be sent' do
      let(:monitor_state) { 'offline' }

      before do
        allow(down_mail).to receive(:deliver_now).and_raise(StandardError, 'missing template')
        allow(Sentry).to receive(:capture_exception)
        run_job
      end

      it 'reports it and keeps the job running' do
        expect(Sentry).to have_received(:capture_exception)
        expect(app_insight).to have_received(:track_event).with("HMRC status email failed at #{now.to_fs(:db)}: missing template")
      end

      it 'tries the email again on the next check' do
        expect(StatusNotification.find_by(service: 'hmrc')).to have_attributes(outage_open: false, sent_count: 0)
      end
    end
  end
end
