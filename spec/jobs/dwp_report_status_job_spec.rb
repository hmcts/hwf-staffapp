require 'rails_helper'

RSpec.describe DwpReportStatusJob do
  describe 'check DWP status' do
    let(:app_insight) { instance_double(ApplicationInsights::TelemetryClient, flush: '') }
    let(:mailer) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }

    before do
      allow(ApplicationInsights::TelemetryClient).to receive(:new).and_return app_insight
      allow(app_insight).to receive(:track_event)
      allow(DwpMonitor).to receive(:new).and_return dwp_monitor
      allow(NotifyMailer).to receive(:dwp_is_down_notifier).and_return mailer
      described_class.perform_now
    end

    context 'offline' do
      let(:dwp_monitor) { instance_double(DwpMonitor, state: 'offline') }
      it { expect(mailer).to have_received(:deliver_now) }
      it { expect(app_insight).to have_received(:track_event).with("Running DWP status check at #{Time.zone.now.to_fs(:db)}") }
      it { expect(app_insight).to have_received(:track_event).with("Sending DWP status is offline notication at #{Time.zone.now.to_fs(:db)}") }
    end

    context 'online' do
      let(:dwp_monitor) { instance_double(DwpMonitor, state: 'online') }
      it { expect(mailer).not_to have_received(:deliver_now) }
      it { expect(app_insight).to have_received(:track_event).with("Running DWP status check at #{Time.zone.now.to_fs(:db)}") }
      it { expect(app_insight).not_to have_received(:track_event).with("Sending DWP status is offline notication at #{Time.zone.now.to_fs(:db)}") }
    end

    context 'warning' do
      let(:dwp_monitor) { instance_double(DwpMonitor, state: 'warning') }
      it { expect(mailer).not_to have_received(:deliver_now) }
      it { expect(app_insight).to have_received(:track_event).with("Running DWP status check at #{Time.zone.now.to_fs(:db)}") }
      it { expect(app_insight).not_to have_received(:track_event).with("Sending DWP status is offline notication at #{Time.zone.now.to_fs(:db)}") }
    end

  end

end
