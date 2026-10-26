require 'rails_helper'

RSpec.describe BenefitCheckers::DwpApiCallRecorder do
  subject(:recorder) { described_class.new(benefit_check) }

  let(:benefit_check) { create(:benefit_check) }

  it 'stores an answered call' do
    recorder.record('get_claims', { guid: 'g' }, { 'data' => [] })
    call = benefit_check.dwp_api_calls.find_by(endpoint_name: 'get_claims')

    expect(call.request_params).to eq('guid' => 'g')
    expect(call.data).to eq('data' => [])
  end

  it 'stores the JSON body of a failed call' do
    error = HwfDwpApiError.new({ 'errors' => [{ 'status' => '404' }] }.to_json, :not_found)
    recorder.record_error('citizen', { guid: 'g' }, error)

    expect(benefit_check.dwp_api_calls.find_by(endpoint_name: 'citizen').data).to eq('errors' => [{ 'status' => '404' }])
  end

  it 'stores a plain error message when the body is not JSON' do
    recorder.record_error('authentication', {}, HwfDwpApiError.new('Connection failed', :connection_error))

    expect(benefit_check.dwp_api_calls.find_by(endpoint_name: 'authentication').data).to eq('error' => 'Connection failed')
  end

  it 'stores nothing without a benefit check' do
    expect { described_class.new(nil).record('get_claims', {}, {}) }.not_to change(DwpApiCall, :count)
  end
end
