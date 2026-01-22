require 'rails_helper'

RSpec.describe PersonalDataPurgeJob do
  let(:purge_class) { instance_double(PersonalDataPurge) }
  let(:app_insight) { instance_double(ApplicationInsights::TelemetryClient, flush: '') }

  describe 'load data' do
    let(:application1) { create(:application) }
    let(:application2) { create(:application) }
    let(:application3) { create(:application, :deleted_state) }
    let(:application4) { create(:application, :deleted_state, completed_at: 8.years.ago) }

    before do
      allow(PersonalDataPurge).to receive(:new).and_return purge_class
      allow(purge_class).to receive(:purge!)
      allow(ApplicationInsights::TelemetryClient).to receive(:new).and_return app_insight
      allow(app_insight).to receive(:track_event)

      travel_to(7.years.ago) do
        application1
        application3
      end
      application4
      application2
      described_class.perform_now
    end

    it { expect(purge_class).to have_received(:purge!) }
    it { expect(PersonalDataPurge).to have_received(:new).with([application1, application3]) }
    it { expect(app_insight).to have_received(:track_event).with("Running personal data purge script: #{Time.zone.today.to_fs(:db)}") }
    it { expect(app_insight).to have_received(:track_event).with("Finished personal data purge script: #{Time.zone.today.to_fs(:db)}, applications affected: 2") }
  end

  describe 'online applicaitons only' do
    let(:application1) { create(:application, online_application: online_application1, created_at: 3.years.ago) }
    let(:online_application1) { create(:online_application_with_all_details, :with_reference, created_at: 8.years.ago) }
    let(:online_application2) { create(:online_application_with_all_details, :with_reference, created_at: 8.years.ago) }
    let(:online_application3) { create(:online_application_with_all_details, :with_reference, created_at: 3.years.ago) }

    before do
      allow(PersonalDataPurge).to receive(:new).and_return purge_class
      allow(purge_class).to receive(:purge_online_only!)
      allow(purge_class).to receive(:purge!)
      allow(ApplicationInsights::TelemetryClient).to receive(:new).and_return app_insight
      allow(app_insight).to receive(:track_event)

      application1
      online_application2
      online_application3

      described_class.perform_now
    end

    it "purge only online_application without linked to application" do
      expect(PersonalDataPurge).to have_received(:new).with([online_application2])
    end

    it { expect(purge_class).to have_received(:purge_online_only!) }
  end
end
