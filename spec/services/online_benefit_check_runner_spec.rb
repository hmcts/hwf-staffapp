require 'rails_helper'

RSpec.describe OnlineBenefitCheckRunner do
  subject(:service) { described_class.new(online_application) }

  before do
    allow(BenefitCheckService).to receive(:new)
  end

  describe 'can_run?' do
    context 'details check' do
      context 'missing name' do
        let(:online_application) { instance_double(OnlineApplication, last_name: '') }
        it { expect(service.can_run?).to be false }
      end

      context 'missing dob' do
        let(:online_application) { instance_double(OnlineApplication, last_name: 'john', date_of_birth: '') }
        it { expect(service.can_run?).to be false }
      end

      context 'missing ni number' do
        let(:online_application) { instance_double(OnlineApplication, last_name: 'john', date_of_birth: '01/01/2000', ni_number: '') }
        it { expect(service.can_run?).to be false }
      end

      context 'all present' do
        let(:online_application) { instance_double(OnlineApplication, last_name: 'john', date_of_birth: '01/01/2000', ni_number: 'SN132465C', date_fee_paid: 1.month.ago) }
        it { expect(service.can_run?).to be true }
      end
    end

    describe 'date check' do
      let(:online_application) { instance_double(OnlineApplication, last_name: 'john', date_of_birth: '01/01/2000', ni_number: 'SN132465C',
          date_fee_paid: date_fee_paid, date_received: date_received) }

      describe 'date_fee_paid' do
        context 'empty' do
          let(:date_fee_paid) { nil }
          let(:date_received) { nil }
          it { expect(service.can_run?).to be false }
        end

        context 'present' do
          let(:date_fee_paid) { 2.months.ago }
          let(:date_received) { nil }
          it { expect(service.can_run?).to be true }
        end
      end

      describe 'date_fee_paid' do
        context 'empty' do
          let(:date_fee_paid) { nil }
          let(:date_received) { nil }
          it { expect(service.can_run?).to be false }
        end

        context 'present' do
          let(:date_fee_paid) { nil }
          let(:date_received) { 1.month.ago }
          it { expect(service.can_run?).to be true }
        end
      end
    end
  end

  describe 'should run?' do
    let(:online_application) { instance_double(OnlineApplication, last_name: 'john', date_of_birth: '01/01/2000', ni_number: 'SN132465C',
        date_fee_paid: date_fee_paid, date_received: date_received, created_at: Time.now, id: 2) }
    before { allow(OnlineBenefitCheck).to receive(:create).and_return 'test' }

    context 'within 3 months' do
      context 'date_received' do
        let(:date_fee_paid) { nil }
        let(:date_received) { 1.month.ago }
        it {
          expect(BenefitCheckService).to receive(:new)
          service.run
        }
      end

      context 'date_fee_paid' do
        let(:date_fee_paid) { 1.month.ago }
        let(:date_received) { nil }
        it {
          expect(BenefitCheckService).to receive(:new)
          service.run
        }
      end
    end

    # This is not needed for online applications
    # context 'outside 3 months' do
    #   context 'date_received' do
    #     let(:date_fee_paid) { nil }
    #     let(:date_received) { 4.month.ago }
    #     it {
    #       expect(BenefitCheckService).not_to receive(:new)
    #       service.run
    #     }
    #   end

    #   context 'date_fee_paid' do
    #     let(:date_fee_paid) { 3.month.ago - 3.day }
    #     let(:date_received) { nil }
    #     it {
    #       expect(BenefitCheckService).not_to receive(:new)
    #       service.run
    #     }
    #   end
    # end
  end

  describe 'online benefit check' do
    let(:online_application) { create(:online_application, date_fee_paid: 1.month.ago) }
    let(:online_benefit_check) { instance_double(OnlineBenefitCheck) }

    before { allow(OnlineBenefitCheck).to receive(:create).and_return online_benefit_check }

    it {
      expect(BenefitCheckService).to receive(:new).with(online_benefit_check)
      service.run
    }
  end

  describe 'online benefit params' do
    let(:online_application) { instance_double(OnlineApplication, last_name: 'john', date_of_birth: '01/01/2000', ni_number: 'SN132465C',
        date_fee_paid: date_fee_paid, date_received: date_received, created_at: Date.parse('1/5/2022 00:00'), id: 2) }
    let(:date_fee_paid) { 1.month.ago }
    let(:date_received) { nil }

    let(:online_bc_params) { {
      online_application: online_application,
      last_name: 'john',
      date_of_birth: '01/01/2000',
      ni_number: 'SN132465C',
      date_to_check: date_fee_paid,
      our_api_token: 'john@220501000000.2'} }

    it {
      expect(OnlineBenefitCheck).to receive(:create).with(hash_including(online_bc_params))
      service.run
    }
  end
end