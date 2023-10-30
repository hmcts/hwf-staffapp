require 'rails_helper'

RSpec.describe FeatureSwitching do
  describe 'is active?' do
    context 'no office' do
      it 'no record' do
        expect(described_class.active?(:test1)).to be false
      end

      it 'not emabled' do
        described_class.create(feature_key: :test1)
        expect(described_class.active?(:test1)).to be false
      end

      it 'enabled' do
        described_class.create(feature_key: :test1, enabled: true)
        expect(described_class.active?(:test1)).to be true
      end

      it 'enabled but not in time yet' do
        described_class.create(feature_key: :test1, enabled: true, activation_time: 2.days.from_now)
        expect(described_class.active?(:test1)).to be false
      end

      it 'enabled but and in time past' do
        described_class.create(feature_key: :test1, enabled: true, activation_time: 1.minute.ago)
        expect(described_class.active?(:test1)).to be true
      end
    end

    context 'office' do
      it 'enabled but wrong office' do
        office = Office.new(id: 1)
        described_class.create(feature_key: :test1, enabled: true, office_id: 2)
        expect(described_class.active?(:test1, office)).to be false
      end

      it 'enabled correct office' do
        office = Office.new(id: 2)
        described_class.create(feature_key: :test1, enabled: true, office_id: 2)
        expect(described_class.active?(:test1, office)).to be true
      end

      it 'disabled correct office' do
        office = Office.new(id: 2)
        described_class.create(feature_key: :test1, enabled: false, office_id: 2)
        expect(described_class.active?(:test1, office)).to be false
      end
    end
  end

  describe 'is subject_to_new_legislation?' do
    context 'no refund' do
      it 'date received after switch' do
        received_and_refund_data = { date_received: Date.parse("27/11/2023"), date_fee_paid: nil, refund: false }
        expect(described_class.subject_to_new_legislation?(received_and_refund_data)).to be true
      end

      it 'date received before switch' do
        received_and_refund_data = { date_received: Date.parse("26/11/2023"), date_fee_paid: nil, refund: false }
        expect(described_class.subject_to_new_legislation?(received_and_refund_data)).to be false
      end
    end
    context 'refund' do
      it 'date received and refunded after switch' do
        received_and_refund_data = { date_received: Date.parse("1/12/2023"), date_fee_paid: Date.parse('27/11/2023'), refund: true }
        expect(described_class.subject_to_new_legislation?(received_and_refund_data)).to be true
      end

      it 'date received and refunded before switch' do
        received_and_refund_data = { date_received: Date.parse("20/11/2023"), date_fee_paid: Date.parse('10/11/2023'), refund: true }
        expect(described_class.subject_to_new_legislation?(received_and_refund_data)).to be false
      end

      it 'date received after switch but refunded before' do
        received_and_refund_data = { date_received: Date.parse("1/12/2023"), date_fee_paid: Date.parse('10/11/2023'), refund: true }
        expect(described_class.subject_to_new_legislation?(received_and_refund_data)).to be false
      end
    end
  end
end
