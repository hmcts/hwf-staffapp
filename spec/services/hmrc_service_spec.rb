# coding: utf-8

require 'rails_helper'

describe HmrcService do
  subject(:service) { described_class.new(application, form) }
  let(:application) { create :application_part_remission }
  let(:evidence_check) { create :evidence_check, application: application }
  let(:hmrc_api) { instance_double(HwfHmrcApi::Connection) }
  let(:form) { instance_double(Forms::Evidence::HmrcCheck, from_date: 'from', to_date: 'to', user_id: 256) }
  let(:applicant) {
    create :applicant,
           date_of_birth: DateTime.new(1968, 2, 28),
           ni_number: 'AB123456C',
           first_name: 'Jimmy',
           last_name: 'Conners',
           application: application
  }

  let(:api_service) { instance_double(HmrcApiService) }
  let(:hmrc_check) { instance_double(HmrcCheck) }

  describe 'load_form_default_data_range' do
    let(:application) { create :application_part_remission, date_received: '4/5/2021', refund: false }
    before {
      allow(form).to receive(:from_date_day=)
      allow(form).to receive(:from_date_month=)
      allow(form).to receive(:from_date_year=)
      allow(form).to receive(:to_date_day=)
      allow(form).to receive(:to_date_month=)
      allow(form).to receive(:to_date_year=)
      service.load_form_default_data_range
    }

    it 'loads dates one month before submitting' do
      expect(form).to have_received(:from_date_day=).with(1)
      expect(form).to have_received(:from_date_month=).with(4)
      expect(form).to have_received(:from_date_year=).with(2021)
      expect(form).to have_received(:to_date_day=).with(30)
      expect(form).to have_received(:to_date_month=).with(4)
      expect(form).to have_received(:to_date_year=).with(2021)
    end

    context 'refund applicaiton' do
      let(:application) { create :application_part_remission, date_received: '4/5/2021', refund: true, date_fee_paid: '4/4/2021' }
      it 'loads dates one month before submitting' do
        expect(form).to have_received(:from_date_day=).with(1)
        expect(form).to have_received(:from_date_month=).with(3)
        expect(form).to have_received(:from_date_year=).with(2021)
        expect(form).to have_received(:to_date_day=).with(31)
        expect(form).to have_received(:to_date_month=).with(3)
        expect(form).to have_received(:to_date_year=).with(2021)
      end
    end
  end

  describe "call" do
    before {
      applicant
      allow(HmrcApiService).to receive(:new).and_return api_service
      allow(api_service).to receive(:match_user).and_return api_service
      allow(Forms::Evidence::HmrcCheck).to receive(:new).and_return form
      allow(api_service).to receive(:income)
      allow(api_service).to receive(:hmrc_check).and_return hmrc_check
      allow(hmrc_check).to receive(:update)
      service.call
    }

    it "calls service with application" do
      expect(HmrcApiService).to have_received(:new).with(application, 256)
    end

    it "calls match_user" do
      expect(api_service).to have_received(:match_user)
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

      it 'saves the error' do
        expect(hmrc_check).to have_received(:update).with({ error_response: 'Error message' })
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
        expect(errors).to have_received(:add).with(:timout, 'HMRC income checking failed. Submit this form again for HMRC income checking')
      end

      it 'saves the error' do
        expect(hmrc_check).to have_received(:update).with({ error_response: 'Net::ReadTimeout - Timeout error' })
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

      it 'saves the error' do
        expect(hmrc_check).to have_received(:update).with({ error_response: 'MESSAGE_THROTTLED_OUT' })
      end
    end

    context 'no hmrc_check' do
      let(:errors) { instance_double(ActiveModel::Errors) }
      before do
        allow(api_service).to receive(:income).and_raise(HwfHmrcApiError.new('MESSAGE_THROTTLED_OUT'))
        allow(form).to receive(:errors).and_return errors
        allow(errors).to receive(:add)
        allow(api_service).to receive(:hmrc_check).and_return nil
      end

      it 'add error' do
        expect { service.call }.not_to raise_error
      end
    end

  end
end
