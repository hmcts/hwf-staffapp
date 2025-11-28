# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeeCodesLoaderService do
  subject(:service) { described_class.new }

  describe '#load_fees' do
    context 'when in local environment' do
      before do
        allow(Rails.env).to receive(:local?).and_return(true)
      end

      it 'loads fake data' do
        fake_data = [{ 'code' => 'FEE0001', 'amount' => 100 }]
        allow(File).to receive(:read).with(FeeCodesLoaderService::FAKE_FEE_CODES_FILE_PATH).and_return(fake_data.to_json)

        result = service.load_fees

        expect(result).to eq(fake_data)
      end
    end

    context 'when loading from file' do
      before do
        allow(Rails.env).to receive(:local?).and_return(false)
        allow(File).to receive(:exist?).with(FeeCodesLoaderService::FEE_CODES_FILE_PATH).and_return(true)
      end

      it 'loads data from file' do
        fake_data = [{ 'code' => 'FEE0001', 'amount' => 100 }]
        allow(File).to receive(:read).with(FeeCodesLoaderService::FEE_CODES_FILE_PATH).and_return(fake_data.to_json)

        result = service.load_fees

        expect(result).to eq(fake_data)
      end
    end

    context 'when loading from api' do
      before do
        allow(Rails.env).to receive(:local?).and_return(false)
        allow(File).to receive(:exist?).with(FeeCodesLoaderService::FEE_CODES_FILE_PATH).and_return(false)
        allow(FregApiService).to receive(:new).and_return(freg_service = instance_double(FregApiService))
        allow(freg_service).to receive(:load_approved_feee).and_return(
          instance_double(Faraday::Response, success?: true, status: 200, body: [{ 'code' => 'FEE0001', 'amount' => 100 }])
        )
      end

      it 'loads data from api' do
        fake_data = [{ 'code' => 'FEE0001', 'amount' => 100 }]
        result = service.load_fees

        expect(result).to eq(fake_data)
      end
    end

    context 'when file contains invalid JSON' do
      before do
        allow(Rails.env).to receive(:local?).and_return(false)
        allow(File).to receive(:exist?).with(FeeCodesLoaderService::FEE_CODES_FILE_PATH).and_return(true)
        allow(File).to receive(:read).with(FeeCodesLoaderService::FEE_CODES_FILE_PATH).and_return('invalid json')
      end

      it 'raises FeeCodesLoadError' do
        expect {
          service.load_fees
        }.to raise_error(FeeCodesLoaderService::FeeCodesLoadError, /Invalid JSON in fee codes file/)
      end
    end

  end

end
