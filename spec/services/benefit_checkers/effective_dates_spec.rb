require 'rails_helper'

RSpec.describe BenefitCheckers::EffectiveDates do
  subject(:dates) { described_class.new(application) }

  # 2026-09-30 is a Wednesday; five weeks earlier is Wednesday 2026-08-26,
  # whose week commences on Monday 2026-08-24.
  let(:date_to) { Date.new(2026, 9, 30) }
  let(:week_commencing) { Date.new(2026, 8, 24) }

  describe 'online application, fee not yet paid' do
    let(:application) { build(:online_application, refund: false, created_at: Time.zone.local(2026, 9, 30, 14, 5)) }

    it 'uses the submission date as the effective to date' do
      expect(dates.effective_to).to eq(date_to)
    end

    it 'starts five weeks earlier at the week commencing date' do
      expect(dates.effective_from).to eq(week_commencing)
    end
  end

  describe 'online application, refund' do
    let(:application) { build(:online_application, refund: true, date_fee_paid: date_to, created_at: Time.zone.local(2026, 10, 20)) }

    it 'uses the date the fee was paid as the effective to date' do
      expect(dates.effective_to).to eq(date_to)
    end
  end

  describe 'paper application, fee not yet paid' do
    let(:application) { build(:application, refund: false, date_received: date_to) }

    it 'uses the date received as the effective to date' do
      expect(dates.effective_to).to eq(date_to)
    end

    it 'starts five weeks earlier at the week commencing date' do
      expect(dates.effective_from).to eq(week_commencing)
    end
  end

  describe 'paper application, refund' do
    let(:application) { build(:application, refund: true, date_fee_paid: date_to, date_received: Date.new(2026, 10, 20)) }

    it 'uses the date the fee was paid as the effective to date' do
      expect(dates.effective_to).to eq(date_to)
    end
  end

  describe '#to_h' do
    let(:application) { build(:application, refund: false, date_received: date_to) }

    it 'formats both dates as YYYY-MM-DD for the DWP API' do
      expect(dates.to_h).to eq(effective_from: '2026-08-24', effective_to: '2026-09-30')
    end

    context 'when the application has no usable date' do
      let(:application) { build(:application, refund: true, date_fee_paid: nil) }

      it 'is empty so the claims call runs without a date filter' do
        expect(dates.to_h).to eq({})
      end
    end
  end
end
