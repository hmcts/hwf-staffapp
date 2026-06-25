require 'rails_helper'

RSpec.describe PowerBiHelper do
  describe '#power_bi_export_title' do
    it 'titles the export by its number' do
      expect(helper.power_bi_export_title('2')).to eq('Power BI export two')
    end
  end

  describe '#power_bi_export_description' do
    it 'returns the description for the export' do
      expect(helper.power_bi_export_description('3')).to eq('Applications by court export (all processing states) for dashboard reporting')
    end
  end

  describe '#power_bi_month_options' do
    before { travel_to(Date.new(2026, 5, 15)) }

    subject(:options) { helper.power_bi_month_options }

    it 'returns 12 months' do
      expect(options.size).to eq(12)
    end

    it 'starts with last month' do
      expect(options.first).to eq(['April 2026', '2026-04'])
    end

    it 'ends 12 months back' do
      expect(options.last).to eq(['May 2025', '2025-05'])
    end

    it 'does not include the current month' do
      expect(options.map(&:last)).not_to include('2026-05')
    end
  end

  describe '#power_bi_default_month' do
    before { travel_to(Date.new(2026, 5, 15)) }

    it 'is the previous month' do
      expect(helper.power_bi_default_month).to eq('2026-04')
    end
  end
end
