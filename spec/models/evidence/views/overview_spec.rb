# coding: utf-8
require 'rails_helper'

RSpec.describe Evidence::Views::Overview do

  let(:user) { create(:user) }
  let(:fee_amount) { '100' }
  let(:application) { create(:application, user: user, office: user.office, fee: fee_amount) }
  let(:evidence) { application.build_evidence_check(expires_at: expiration_date) }
  let(:overview) { described_class.new(evidence) }
  symbols = %i[reference processed_by expires date_of_birth full_name ni_number status fee jurisdiction date_received form_name]

  symbols.each do |symbol|
    let(:expiration_date) { Time.zone.today + 14.days }
    it 'has the attribute #{symbol} for "Processing details" section' do
      expect(overview.methods).to include(symbol)
    end
  end

  describe '#expires' do
    context 'when the evidence check expires in a few days' do
      let(:expiration_date) { Time.zone.now + 3.days }

      it { expect(overview.expires).to eq '3 days' }
    end

    context 'when the evidence check expires today' do
      let(:expiration_date) { Time.zone.now }

      it { expect(overview.expires).to eq 'expired' }
    end

    context 'when the evidence check has expired' do
      let(:expiration_date) { Time.zone.today - 1 }

      it { expect(overview.expires).to eq 'expired' }
    end
  end

  describe '#jurisdiction' do
    it { expect(overview.jurisdiction).to eq application.jurisdiction.name }
  end

  describe '#fee' do
    context 'rounds down' do
      let(:fee_amount) { '100.49' }

      it 'formats the fee amount correctly' do
        expect(overview.fee).to eq 100
      end
    end

    context 'when its under £1' do
      let(:fee_amount) { '0.49' }

      it 'formats the fee amount correctly' do
        expect(overview.fee).to eq 0
      end
    end
  end
end
