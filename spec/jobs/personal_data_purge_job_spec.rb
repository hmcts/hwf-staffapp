require 'rails_helper'

RSpec.describe PersonalDataPurgeJob, type: :job do

  describe 'load data' do
    let(:application1) { create :application }
    let(:application2) { create :application }
    let(:application3) { create :application, :deleted_state }
    let(:purge_class) { instance_double(PersonalDataPurge) }
    let(:app_insight) { instance_double(ApplicationInsights::TelemetryClient, flush: '') }

    before do
      allow(PersonalDataPurge).to receive(:new).and_return purge_class
      allow(purge_class).to receive(:purge!)
      allow(ApplicationInsights::TelemetryClient).to receive(:new).and_return app_insight
      allow(app_insight).to receive(:track_event)

      Timecop.freeze(7.years.ago) do
        application1
        application3
      end
      application2
      described_class.perform_now
    end

    it { expect(purge_class).to have_received(:purge!) }
    it { expect(PersonalDataPurge).to have_received(:new).with([application1, application3]) }
    it { expect(app_insight).to have_received(:track_event).with("Running Personal data purge script: #{Time.zone.now.to_fs(:db)}") }
    it { expect(app_insight).to have_received(:track_event).with("Finished personal data purge script: #{Time.zone.now.to_fs(:db)}, applications affected: 2") }
  end
end
