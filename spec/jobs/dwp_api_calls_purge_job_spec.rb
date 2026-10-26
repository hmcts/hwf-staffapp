require 'rails_helper'

# Removes the stored DWP JSON after the configured number of months; the
# benefit check and the export columns on it are untouched. See CHANGELOG.md
RSpec.describe DwpApiCallsPurgeJob do
  let(:app_insight) { instance_double(ApplicationInsights::TelemetryClient, flush: '', track_event: nil) }
  let(:benefit_check) { create(:benefit_check, dwp_result: 'Yes', benefit_types: 'universal_credit', claim_status: 'active', take_home_pay: 41_050) }

  let!(:recent_call) { travel_to(2.months.ago) { create(:dwp_api_call, benefit_check: benefit_check) } }
  let!(:old_call) do
    travel_to(6.months.ago - 1.day) do
      create(:dwp_api_call, benefit_check: benefit_check, endpoint_name: 'get_claims',
                            request_params: { guid: 'abc-123-guid', effective_from: '2026-02-23', effective_to: '2026-03-30' })
    end
  end
  let!(:older_call) { travel_to(9.months.ago) { create(:dwp_api_call, benefit_check: benefit_check, endpoint_name: 'citizen') } }
  let(:earlier_purge) { 3.months.ago }
  let!(:already_purged) do
    purged_at = earlier_purge
    travel_to(9.months.ago) do
      create(:dwp_api_call, benefit_check: benefit_check, data: nil, request_params: nil, purged_at: purged_at)
    end
  end

  before do
    allow(ApplicationInsights::TelemetryClient).to receive(:new).and_return(app_insight)
    allow(Settings).to receive(:dwp_api_calls_purge).and_return(Config::Options.new(months_ago: 6))
    described_class.perform_now
  end

  it 'removes the response JSON from calls older than the configured months' do
    [old_call, older_call].each do |call|
      call.reload
      expect(call.data).to be_nil
      expect(call.purged_at).to be_within(1.minute).of(Time.zone.now)
    end
  end

  it 'keeps a claims request whole, date window and guid' do
    expect(old_call.reload.request_params).to eq('guid' => 'abc-123-guid', 'effective_from' => '2026-02-23', 'effective_to' => '2026-03-30')
  end

  it 'removes a request that is about the person' do
    expect(older_call.reload.request_params).to be_nil
    expect(recent_call.reload.request_params).to be_present
  end

  it 'keeps what the call was and when' do
    old_call.reload
    expect(old_call.endpoint_name).to eq 'get_claims'
    expect(old_call.response_status).to eq 200
    expect(old_call.benefit_check_id).to eq benefit_check.id
    expect(old_call.created_at).to be_within(1.day).of(6.months.ago - 1.day)
  end

  it 'leaves recent calls alone' do
    recent_call.reload
    expect(recent_call.data).to be_present
    expect(recent_call.request_params).to be_present
    expect(recent_call.purged_at).to be_nil
  end

  it 'does not purge the same call twice' do
    expect(already_purged.reload.purged_at).to be_within(1.minute).of(earlier_purge)
  end

  it 'leaves the benefit check and its export columns alone' do
    benefit_check.reload
    expect([benefit_check.dwp_result, benefit_check.benefit_types, benefit_check.claim_status, benefit_check.take_home_pay]).
      to eq(['Yes', 'universal_credit', 'active', 41_050])
  end

  it 'logs the run and how many calls it purged' do
    expect(app_insight).to have_received(:track_event).with(/Running DWP API calls purge/)
    expect(app_insight).to have_received(:track_event).with(/Finished DWP API calls purge.*calls purged: 2/)
  end

  context 'with a different number of months configured' do
    before do
      allow(Settings).to receive(:dwp_api_calls_purge).and_return(Config::Options.new(months_ago: 1))
      described_class.perform_now
    end

    it 'uses it' do
      expect(recent_call.reload.data).to be_nil
    end
  end
end
