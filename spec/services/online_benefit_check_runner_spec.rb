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
      let(:online_application) {
        instance_double(OnlineApplication, last_name: 'john', date_of_birth: '01/01/2000', ni_number: 'SN132465C',
                                           date_fee_paid: date_fee_paid, date_received: date_received)
      }

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

      describe 'date_received' do
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
    let(:online_application) {
      instance_double(OnlineApplication, last_name: 'john', date_of_birth: '01/01/2000', ni_number: 'SN132465C',
                                         date_fee_paid: date_fee_paid, date_received: date_received, created_at: Time.zone.now, id: 2)
    }
    before {
      allow(BenefitCheck).to receive(:create).and_return 'test'
      allow(BenefitCheckService).to receive(:new)
    }

    context 'within 3 months' do
      context 'date_received' do
        let(:date_fee_paid) { nil }
        let(:date_received) { 1.month.ago }
        it {
          service.run
          expect(BenefitCheckService).to have_received(:new)
        }
      end

      context 'date_fee_paid' do
        let(:date_fee_paid) { 1.month.ago }
        let(:date_received) { nil }
        it {
          service.run
          expect(BenefitCheckService).to have_received(:new)
        }
      end
    end
  end

  describe 'online benefit check' do
    let(:online_application) { create(:online_application, date_fee_paid: 1.month.ago) }
    let(:online_benefit_check) { instance_double(BenefitCheck) }

    before {
      allow(BenefitCheck).to receive(:create).and_return online_benefit_check
      allow(BenefitCheckService).to receive(:new)
    }

    it {
      service.run
      expect(BenefitCheckService).to have_received(:new).with(online_benefit_check)
    }
  end

  describe 'online benefit params' do
    let(:online_application) {
      instance_double(OnlineApplication, last_name: 'john', date_of_birth: '01/01/2000', ni_number: 'SN132465C',
                                         date_fee_paid: date_fee_paid, date_received: date_received, created_at: Date.parse('1/5/2022 00:00'), id: 2)
    }
    let(:date_fee_paid) { 1.month.ago }
    let(:date_received) { nil }

    let(:online_bc_params) {
      {
        applicationable: online_application,
        last_name: 'john',
        date_of_birth: '01/01/2000',
        ni_number: 'SN132465C',
        date_to_check: date_fee_paid,
        our_api_token: 'john@220501000000.2'
      }
    }
    before {
      allow(BenefitCheck).to receive(:create)
    }
    it {
      service.run
      expect(BenefitCheck).to have_received(:create).with(hash_including(online_bc_params))
    }
  end
end
