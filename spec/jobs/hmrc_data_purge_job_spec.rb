require 'rails_helper'

RSpec.describe HmrcDataPurgeJob do
  describe 'purge old hmrc checks' do

    let(:application) { create(:application) }
    let(:evidence_check) { create(:evidence_check, application: application) }
    let(:hmrc_check_1) { create(:hmrc_check, evidence_check: evidence_check) }
    let(:hmrc_check_2) { create(:hmrc_check, evidence_check: evidence_check) }
    let(:hmrc_check_3) { create(:hmrc_check, evidence_check: evidence_check) }
    let(:hmrc_check_4) { create(:hmrc_check, evidence_check: evidence_check, purged_at: Date.parse('1/1/2018')) }

    context "Hmrc check list for last six months" do
      let(:app_insight) { instance_double(ApplicationInsights::TelemetryClient, flush: '') }

      before do
        allow(ApplicationInsights::TelemetryClient).to receive(:new).and_return app_insight
        allow(app_insight).to receive(:track_event)

        travel_to(2.months.ago) do
          hmrc_check_1
        end
        travel_to(6.months.ago - 1.day) do
          hmrc_check_2
        end
        travel_to(7.months.ago) do
          hmrc_check_3
        end
        travel_to(7.months.ago) do
          hmrc_check_4
        end

        described_class.perform_now
        hmrc_check_1.reload
        hmrc_check_2.reload
        hmrc_check_3.reload
        hmrc_check_4.reload
      end

      context 'purged' do
        it { expect(hmrc_check_2.address).to be_nil }
        it { expect(hmrc_check_2.income).to be_nil }
        it { expect(hmrc_check_2.employment).to be_nil }
        it { expect(hmrc_check_2.tax_credit).to be_nil }
        it { expect(hmrc_check_2.date_of_birth).not_to be_nil }
        it { expect(hmrc_check_2.ni_number).not_to be_nil }
        it { expect(hmrc_check_2.evidence_check_id).not_to be_nil }
        it { expect(hmrc_check_2.purged_at.to_fs(:short)).to eq(Time.zone.now.to_fs(:short)) }
        it { expect(app_insight).to have_received(:track_event).with("Purging HMRC data check id:#{hmrc_check_2.id} at #{Time.zone.now.to_fs(:short)}") }

        it { expect(hmrc_check_3.address).to be_nil }
        it { expect(hmrc_check_3.income).to be_nil }
        it { expect(hmrc_check_3.employment).to be_nil }
        it { expect(hmrc_check_3.tax_credit).to be_nil }
        it { expect(hmrc_check_3.date_of_birth).not_to be_nil }
        it { expect(hmrc_check_3.ni_number).not_to be_nil }
        it { expect(hmrc_check_3.evidence_check_id).not_to be_nil }
        it { expect(hmrc_check_3.purged_at.to_fs(:short)).to eq(Time.zone.now.to_fs(:short)) }
        it { expect(app_insight).to have_received(:track_event).with("Purging HMRC data check id:#{hmrc_check_3.id} at #{Time.zone.now.to_fs(:short)}") }
      end

      context 'left alone' do
        it { expect(hmrc_check_1.address).not_to be_nil }
        it { expect(hmrc_check_1.income).not_to be_nil }
        it { expect(hmrc_check_1.employment).not_to be_nil }
        it { expect(hmrc_check_1.tax_credit).not_to be_nil }
        it { expect(hmrc_check_1.purged_at).to be_nil }
        it { expect(hmrc_check_1.date_of_birth).not_to be_nil }
        it { expect(hmrc_check_1.ni_number).not_to be_nil }
        it { expect(hmrc_check_1.evidence_check_id).not_to be_nil }
        it { expect(app_insight).not_to have_received(:track_event).with("Purging HMRC data check id:#{hmrc_check_1.id} at #{Time.zone.now.to_fs(:db)}") }

        # Do not purge already purged data
        it { expect(hmrc_check_4.purged_at).to eq Date.parse('1/1/2018') }
        it { expect(hmrc_check_4.date_of_birth).not_to be_nil }
        it { expect(hmrc_check_4.ni_number).not_to be_nil }
        it { expect(hmrc_check_4.evidence_check_id).not_to be_nil }
        it { expect(app_insight).not_to have_received(:track_event).with("Purging HMRC data check id:#{hmrc_check_4.id} at #{Time.zone.now.to_fs(:db)}") }
      end
    end
  end
end
