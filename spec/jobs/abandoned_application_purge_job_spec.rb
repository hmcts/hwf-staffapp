require 'rails_helper'

RSpec.describe AbandonedApplicationPurgeJob do
  describe 'purge old applications' do

    let(:application1) { create(:application, state: 0) }
    let(:application2) { create(:application, state: 0) }
    let(:application3) { create(:application, state: 0) }
    let(:application4) { create(:application, state: 1) }
    let(:application5) { create(:application, state: 2) }
    let(:app_insight) { instance_double(ApplicationInsights::TelemetryClient, flush: '') }

    before do
      travel_to(30.days.ago) { application1 }
      travel_to(28.days.ago) { application2 }
      travel_to(1.day.ago) { application3 }
      travel_to(30.days.ago) { application4 }
      travel_to(30.days.ago) { application5 }

      allow(ApplicationInsights::TelemetryClient).to receive(:new).and_return app_insight
      allow(app_insight).to receive(:track_event)

      described_class.perform_now
    end

    context "Destroy old application with state 0 older then 28 days" do
      it {
        expect { application1.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect { application2.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect(application3.reload).not_to be_nil
        expect(application4.reload).not_to be_nil
        expect(application5.reload).not_to be_nil
        expect(app_insight).to have_received(:track_event).with("Running Abandoned application purge data script #{Time.zone.today}")
        expect(app_insight).to have_received(:track_event).with("Finished Abandoned application purge data script #{Time.zone.today}")
      }
    end
  end
end
