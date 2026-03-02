# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeeCodesLoaderService do
  subject(:service) { described_class.new }

  let(:todays_file_path) { described_class.fee_codes_file_path }

  describe '#load_fees' do
    context 'when in test environment' do
      it 'loads fake data' do
        fake_data = [{ 'code' => 'FEE0001', 'amount' => 100 }]
        allow(File).to receive(:read)
          .with(FeeCodesLoaderService::FAKE_FEE_CODES_FILE_PATH)
          .and_return(fake_data.to_json)

        result = service.load_fees

        expect(result).to eq(fake_data)
      end
    end

    context 'when loading from dated file' do
      before do
        allow(Rails.env).to receive(:test?).and_return(false)
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with(todays_file_path).and_return(true)
      end

      it 'loads data from the dated file' do
        fake_data = [{ 'code' => 'FEE0001', 'amount' => 100 }]
        allow(File).to receive(:read).with(todays_file_path).and_return(fake_data.to_json)

        result = service.load_fees

        expect(result).to eq(fake_data)
      end
    end

    context 'when loading from api' do
      before do
        allow(Rails.env).to receive(:test?).and_return(false)
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with(todays_file_path).and_return(false)
        allow(File).to receive(:write)
        allow(FeeCodesFreshnessChecker).to receive(:cleanup_old_files!)
        allow(FregApiService).to receive(:new).and_return(freg_service)
        allow(freg_service).to receive(:load_approved_feee).and_return(api_response)
      end

      let(:freg_service) { instance_double(FregApiService) }
      let(:api_response) do
        instance_double(Faraday::Response, success?: true, status: 200,
                                           body: [{ 'code' => 'FEE0001', 'amount' => 100 }])
      end

      it 'loads data from api' do
        result = service.load_fees
        expect(result).to eq([{ 'code' => 'FEE0001', 'amount' => 100 }])
      end

      it 'stores the file with todays date' do
        service.load_fees
        expect(File).to have_received(:write).with(todays_file_path, anything)
      end
    end

    context 'when file contains invalid JSON' do
      before do
        allow(Rails.env).to receive(:test?).and_return(false)
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with(todays_file_path).and_return(true)
        allow(File).to receive(:read).with(todays_file_path).and_return('invalid json')
      end

      it 'raises FeeCodesLoadError' do
        expect {
          service.load_fees
        }.to raise_error(FeeCodesLoaderService::FeeCodesLoadError, /Invalid JSON in fee codes file/)
      end
    end
  end

  describe '.fee_codes_file_path' do
    it 'returns a path with todays date' do
      expected = Rails.root.join("tmp/approvedFees_#{Time.zone.today.strftime('%Y-%m-%d')}.json")
      expect(described_class.fee_codes_file_path).to eq(expected)
    end

    it 'accepts a custom date' do
      date = Date.new(2026, 1, 15)
      expected = Rails.root.join("tmp/approvedFees_2026-01-15.json")
      expect(described_class.fee_codes_file_path(date)).to eq(expected)
    end
  end
end
