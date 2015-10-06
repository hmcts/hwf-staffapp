require 'rails_helper'

RSpec.describe Evidence::Views::Overview do

  let(:user) { create(:user) }
  let(:application) { create(:application, user: user, office: user.office) }
  let(:evidence) { application.build_evidence_check(expires_at: expiration_date) }
  let(:overview) { Evidence::Views::Overview.new(evidence) }

  %i[reference processed_by expires date_of_birth full_name ni_number status].each do |symbol|
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

end
