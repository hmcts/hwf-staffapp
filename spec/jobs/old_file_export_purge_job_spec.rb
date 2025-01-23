require 'rails_helper'

RSpec.describe OldFileExportPurgeJob do
  describe 'purge old applications' do
    let(:user) { create(:user) }
    let(:storage_1) { create(:export_file_storage, user: user) }
    let(:storage_2) { create(:export_file_storage, user: user) }
    let(:storage_3) { create(:export_file_storage, user: user) }
    let(:app_insight) { instance_double(ApplicationInsights::TelemetryClient, flush: '') }

    before do
      Timecop.freeze(2.days.ago) { storage_1 }
      Timecop.freeze(1.day.ago) { storage_2 }
      Timecop.freeze(23.hours.ago) { storage_3 }

      allow(ApplicationInsights::TelemetryClient).to receive(:new).and_return app_insight
      allow(app_insight).to receive(:track_event)

      described_class.perform_now
    end

    context "Destroy old export files older then 24 hours" do
      it {
        expect { storage_1.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect { storage_1.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect(storage_3.reload).not_to be_nil
        expect(app_insight).to have_received(:track_event).with("Running old export files purge script #{Time.zone.today}")
        expect(app_insight).to have_received(:track_event).with("Finished old export files purge script #{Time.zone.today}")
      }
    end
  end
end
