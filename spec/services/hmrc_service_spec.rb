# coding: utf-8

require 'rails_helper'

describe HmrcService do
  subject(:service) { described_class.new(application, form) }
  let(:application) { create :application_part_remission, applicant: applicant }
  let(:evidence_check) { create :evidence_check, application: application }
  let(:hmrc_api) { instance_double(HwfHmrcApi::Connection) }
  let(:form) { instance_double(Forms::Evidence::HmrcCheck, from_date: 'from', to_date: 'to') }
  let(:applicant) {
    create :applicant,
           date_of_birth: DateTime.new(1968, 2, 28),
           ni_number: 'AB123456C',
           first_name: 'Jimmy',
           last_name: 'Conners'
  }


  let(:api_service) { instance_double(HmrcApiService) }


  describe "call" do
    before {
      allow(HmrcApiService).to receive(:new).and_return api_service
      allow(Forms::Evidence::HmrcCheck).to receive(:new).and_return form
      allow(api_service).to receive(:income)
      allow(api_service).to receive(:hmrc_check)
      service.call
    }

    it "calls service with application" do
      expect(HmrcApiService).to have_received(:new).with(application)
    end

    it "load income" do
      expect(api_service).to have_received(:income).with('from', 'to')
    end

    it "load hmrc_check" do
      expect(api_service).to have_received(:hmrc_check)
    end

    context 'fail' do
      let(:errors) { instance_double(ActiveModel::Errors) }
      before do
        allow(api_service).to receive(:income).and_raise(HwfHmrcApiError.new('Error message'))
        allow(form).to receive(:errors).and_return errors
        allow(errors).to receive(:add)
        service.call
      end

      it 'add error' do
        expect(errors).to have_received(:add).with(:request, 'Error message')
      end
    end

    context 'fail - timeout' do
      let(:errors) { instance_double(ActiveModel::Errors) }
      before do
        allow(api_service).to receive(:income).and_raise(Net::ReadTimeout.new('Error message'))
        allow(form).to receive(:errors).and_return errors
        allow(errors).to receive(:add)
        service.call
      end

      it 'add error' do
        expect(errors).to have_received(:add).with(:timout, 'HMRC income checking failed. Submit this form for HMRC income checking')
      end
    end

    context 'fail - MESSAGE_THROTTLED_OUT' do
      let(:errors) { instance_double(ActiveModel::Errors) }
      before do
        allow(api_service).to receive(:income).and_raise(HwfHmrcApiError.new('MESSAGE_THROTTLED_OUT'))
        allow(form).to receive(:errors).and_return errors
        allow(errors).to receive(:add)
        service.call
      end

      it 'add error' do
        expect(errors).to have_received(:add).with(:request, 'HMRC checking is currently unavailable please try again later. (429)')
      end
    end

  end
end
